%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(artifact_handler).

-include("arti.hrl").
-include("game.hrl").
-include("role.hrl").
-include("item.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("log.hrl").
-include("errno.hrl").
-include("equip.hrl").
-include("enum.hrl").
-include("msgno.hrl").

%% API
-export([handle/3]).
-export([get_attr/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?ARTIFACT_LIST, _Tos, RoleSt) ->
	Data = role_data:get(?DB_ROLE_ARTIFACT),
	?ucast(#m_artifact_list_toc{
		artis = lists:map(fun
			(Arti) ->
				Equips = maps:map(fun
					(_, E) ->
						item_util:p_item(E)
				end, Arti#p_artifact.equips),
				Arti#p_artifact{equips=Equips}
		end, maps:values(Data#role_artifact.artis))
	});

handle(?ARTIELEM_LIST, Tos, RoleSt) ->
	#m_artielem_list_tos{type=Type} = Tos,
	Data = role_data:get(?DB_ROLE_ARTIFACT),
	?ucast(#m_artielem_list_toc{
		type  = Type,
		elems = maps:get(Type, Data#role_artifact.elems, [])
	});

handle(?ARTIELEM_UPGRADE, Tos, RoleSt) ->
	#m_artielem_upgrade_tos{arti_type=Type, elem_id=Eid} = Tos,
	Data = role_data:get(?DB_ROLE_ARTIFACT),
	#role_artifact{artis=Artis, elems=Elems} = Data,
	List = maps:get(Type, Elems, []),
	Elem = keyfind(Eid, #p_artielem.id, List, #p_artielem{id=Eid, level=0}),

	Conf = cfg_artifact_element:find(Type, Eid, Elem#p_artielem.level+1),
	?_check(Conf /= ?nil, ?ERR_ARTI_ELEM_MAX_LEVEL),
	#cfg_artifact_element{name=Name, cost=Cost} = Conf,
	role_bag:cost(Cost, ?LOG_ARTIELEM_UPGRADE, RoleSt),

	Elem2  = Elem#p_artielem{level=Elem#p_artielem.level+1},
	List2  = lists:keystore(Eid, #p_artielem.id, List, Elem2),
	Elems2 = maps:put(Type, List2, Elems),
	Data1  = Data#role_artifact{elems=Elems2},

	UnlockReqs = cfg_artifact_unlock:unlock_artifact(Type),
	IsUnlock  = lists:all(fun
		({Eid0, Lv}) ->
			Elem0 = keyfind(Eid0, #p_artielem.id, List2, #p_artielem{level=0}),
			Elem0#p_artielem.level >= Lv
	end, UnlockReqs),

	Data2  = case IsUnlock of
		true  ->
			Artis2 = lists:foldl(fun
				(Aid, Acc) ->
					NewArti = #p_artifact{
						id        = Aid,
						reinf_lv  = 0,
						reinf_exp = 0,
						equips    = #{},
						enchant   = #{}
					},
					case maps:is_key(Aid, Acc) of
						true ->
							Acc;
						false ->
							maps:put(Aid, NewArti, Acc)
					end
			end, Artis, cfg_artifact_unlock:artifacts(Type)),
			Data1#role_artifact{artis=Artis2};
		false ->
			Data1
	end,
	role_data:set(Data2),

	role_attr:recalc(?MODULE, RoleSt),

	case Elem2#p_artielem.level rem 10 == 0 of
		true  ->
			#role_st{role=RoleID, name=RoleName} = RoleSt,
			?notify(?MSG_ELEMENT, [
				{role, RoleID, RoleName},
				cfg_artifact_unlock:artifact_typename(Type),
				Name,
				Elem2#p_artielem.level
			]);
		false ->
			ignore
	end,

	?ucast(#m_artielem_upgrade_toc{arti_type=Type, elem_id=Eid, is_unlock=IsUnlock});

handle(?ARTIFACT_REINF, Tos, RoleSt) ->
	#m_artifact_reinf_tos{arti_id=Aid, materials=Mats} = Tos,

	?_check(ut_misc:is_unique(Mats), ?ERR_GAME_BAD_ARGS),

	Data = #role_artifact{artis=Artis} = role_data:get(?DB_ROLE_ARTIFACT),
	Arti = maps:get(Aid, Artis, ?nil),
	?_check(Artis /= ?nil, ?ERR_ARTI_NOT_UNLOCK),

	Conf = cfg_artifact_reinf:find(Aid, Arti#p_artifact.reinf_lv+1),
	?_check(Conf /= ?nil, ?ERR_ARTI_MAX_REINF),

	ExpAdd = lists:foldl(fun
		(Uid, Acc) ->
			{ok, Item} = role_bag:get_item(Uid),
			#cfg_item{effect=Add0} = cfg_item:find(Item#p_item.id),
			Acc + Add0 * Item#p_item.num
	end, 0, Mats),

	role_bag:cost([{cellid,Uid} || Uid <- Mats], ?LOG_ARTIFACT_REINF, RoleSt),

	Arti1 = Arti#p_artifact{reinf_exp=Arti#p_artifact.reinf_exp+ExpAdd},
	Arti2 = maybe_upgrade(Arti1),
	Data2 = Data#role_artifact{artis=maps:put(Aid, Arti2, Artis)},

	role_data:set(Data2),

	role_attr:recalc(?MODULE, RoleSt),

	lists:foreach(fun
		(Lv) ->
			case Lv rem 10 == 0 of
				true  ->
					#role_st{role=RoleID, name=RoleName} = RoleSt,
					?notify(?MSG_STRENGTHEN, [
						{role, RoleID, RoleName},
						cfg_artifact_unlock:artifact_name(Aid),
						Lv
					]);
				false ->
					ignore
			end
	end, lists:seq(Arti#p_artifact.reinf_lv+1, Arti2#p_artifact.reinf_lv)),

	?ucast(#m_artifact_reinf_toc{
		arti_id   = Aid,
		reinf_lv  = Arti2#p_artifact.reinf_lv,
		reinf_exp = Arti2#p_artifact.reinf_exp
	});

handle(?ARTIFACT_PUTON, Tos, RoleSt) ->
	#m_artifact_puton_tos{arti_id=Aid, item_uid=ItemUid} = Tos,

	Data = #role_artifact{artis=Artis} = role_data:get(?DB_ROLE_ARTIFACT),
	Arti = maps:get(Aid, Artis, ?nil),
	?_check(Artis /= ?nil, ?ERR_ARTI_NOT_UNLOCK),

	#p_artifact{equips=Equips, enchant=Enchant} = Arti,
	{ok, Equip} = role_bag:get_item(ItemUid),
	#cfg_item{stype=SType} = cfg_item:find(Equip#p_item.id),
	?_check(SType == Aid, ?ERR_GAME_BAD_ARGS),

	#cfg_equip{slot=SlotId} = cfg_equip:find(Equip#p_item.id),
	Old = maps:get(SlotId, Equips, ?nil),

	Cost = [{cellid, ItemUid, 1}],
	Gain = ?_if(Old == ?nil, [], [Old]),
	role_bag:deal(Cost, Gain, ?LOG_ARTIFACT_PUTON, RoleSt),

	Equips2 = maps:put(SlotId, Equip, Equips),

	{[{UnlNum,UnlColor}],_,_,_} = cfg_artifact_unlock:unlock_enchant(Aid),

	IsUnlock = case maps:size(Enchant) == 0 andalso maps:size(Equips2) == UnlNum of
		true  ->
			lists:all(fun
				(E) ->
					#cfg_item{color=Color} = cfg_item:find(E#p_item.id),
					Color >= UnlColor
			end, maps:values(Equips2));
		false ->
			false
	end,

	Arti1 = case IsUnlock of
		true  ->
			#cfg_artifact_enchant{code=Code, base=Val} = cfg_artifact_enchant:find(Aid,1),
			Arti#p_artifact{enchant=maps:put(Code, Val, Enchant)};
		false ->
			Arti
	end,
	Arti2 = Arti1#p_artifact{equips=Equips2},
	Data2 = Data#role_artifact{artis=maps:put(Aid, Arti2, Artis)},
	role_data:set(Data2),

	role_attr:recalc(?MODULE, RoleSt),

	?ucast(#m_artifact_puton_toc{arti_id=Aid, slot_id=SlotId, is_unlock=IsUnlock});

handle(?ARTIFACT_PUTOFF, Tos, RoleSt) ->
	#m_artifact_putoff_tos{arti_id=Aid, slot_id=SlotId} = Tos,

	Data = #role_artifact{artis=Artis} = role_data:get(?DB_ROLE_ARTIFACT),
	Arti = maps:get(Aid, Artis, ?nil),
	?_check(Artis /= ?nil, ?ERR_ARTI_NOT_UNLOCK),

	#p_artifact{equips=Equips} = Arti,
	Equip = maps:get(SlotId, Equips, ?nil),
	?_check(Equip /= ?nil, ?ERR_ARTI_NOT_PUTON),

	role_bag:gain([Equip], ?LOG_ARTIFACT_PUTOFF, RoleSt),

	Arti2 = Arti#p_artifact{equips=maps:remove(SlotId, Equips)},
	Data2 = Data#role_artifact{artis=maps:put(Aid, Arti2, Artis)},
	role_data:set(Data2),

	role_attr:recalc(?MODULE, RoleSt),

	?ucast(#m_artifact_putoff_toc{arti_id=Aid, slot_id=SlotId});

handle(?ARTIFACT_ENCHANT, Tos, RoleSt) ->
	#m_artifact_enchant_tos{arti_id=Aid} = Tos,

	Data = #role_artifact{artis=Artis} = role_data:get(?DB_ROLE_ARTIFACT),
	Arti = maps:get(Aid, Artis, ?nil),
	?_check(Artis /= ?nil, ?ERR_ARTI_NOT_UNLOCK),

	#p_artifact{enchant=Enchant, reinf_lv=ReinfLv, equips=Equips} = Arti,
	?_check(Enchant /= #{}, ?ERR_ARTI_ENCHANT_NOT_ACTIVE),
	?_check(maps:size(Equips) == 3, ?ERR_ARTI_CANNOT_ENCHANT),

	#cfg_artifact_reinf{enchant=Multi} = cfg_artifact_reinf:find(Aid, ReinfLv),
	{_,[{_,UnlVal2}],[{_,UnlVal3}],[{_,UnlVal4}]} = cfg_artifact_unlock:unlock_enchant(Aid),

	Enchant2 = lists:foldl(fun
		(Nth, Acc) ->
			#cfg_artifact_enchant{code=Code, max=Max, add=Add} = cfg_artifact_enchant:find(Aid, Nth),
			OldVal = maps:get(Code, Enchant, ?nil),
			MaxVal = ut_math:ceil(Max*?_per(Multi)),
			?debug("---------------:~w", [{OldVal, MaxVal}]),
			case OldVal == ?nil orelse OldVal >= MaxVal of
				true  ->
					Acc;
				false ->
					AddVal = calc_enchant_add(Add, OldVal),
					NewVal = OldVal + AddVal,
					Acc1 = maps:put(Code, NewVal, Acc),
					case Nth of
						1 ->
							case maps:size(Enchant) == 1 andalso NewVal >= UnlVal2 of
								true  ->
									#cfg_artifact_enchant{code=Code2, base=Val} = cfg_artifact_enchant:find(Aid,2),
									maps:put(Code2, Val, Acc1);
								false ->
									Acc1
							end;
						2 ->
							case maps:size(Enchant) == 2 andalso NewVal >= UnlVal3 of
								true  ->
									#cfg_artifact_enchant{code=Code2, base=Val} = cfg_artifact_enchant:find(Aid,3),
									maps:put(Code2, Val, Acc1);
								false ->
									Acc1
							end;
						3 ->
							case maps:size(Enchant) == 3 andalso NewVal >= UnlVal4 of
								true  ->
									#cfg_artifact_enchant{code=Code2, base=Val} = cfg_artifact_enchant:find(Aid,4),
									maps:put(Code2, Val, Acc1);
								false ->
									Acc1
							end;
						_ ->
							Acc1
					end
			end
	end, Enchant, lists:seq(1, 4)),

	?_check(Enchant /= Enchant2, ?ERR_ARTI_ENCHANT_MAX),

	Cost = cfg_artifact_enchant:cost(Aid),
	role_bag:cost(Cost, ?LOG_ARTIFACT_ENCHANT, RoleSt),

	Arti2  = Arti#p_artifact{enchant=Enchant2},
	Data2  = Data#role_artifact{artis=maps:put(Aid, Arti2, Artis)},

	role_data:set(Data2),

	role_attr:recalc(?MODULE, RoleSt),

	?ucast(#m_artifact_enchant_toc{arti_id=Aid, enchant=Enchant2}).

get_attr(_AttrType) ->
	#role_artifact{artis=Artis, elems=Elems} = role_data:get(?DB_ROLE_ARTIFACT),
	Attrs1 = maps:fold(fun
		(Type, ElemList, Acc1) ->
			lists:foldl(fun
				(Elem, Acc2) ->
					#p_artielem{id=Eid, level=Lv} = Elem,
					#cfg_artifact_element{attrs=Attrs} = cfg_artifact_element:find(Type, Eid, Lv),
					mod_attr:add(Acc2, Attrs)
			end, Acc1, ElemList)
	end, #{}, Elems),
	Attrs2 = maps:fold(fun
		(Aid, Arti, Acc) ->
			#p_artifact{reinf_lv=ReinfLv, enchant=Enchant, equips=Equips} = Arti,
			case cfg_artifact_reinf:find(Aid, ReinfLv) of
				#cfg_artifact_reinf{attrs=Tmp1} ->
					ok;
				_ ->
					Tmp1 = #{}
			end,
			Tmp2 = case maps:size(Equips) == 3 of
				true  -> Enchant;
				false -> #{}
			end,
			Fin1 = mod_attr:add(Tmp1, Tmp2),

			Tmp3 = maps:fold(fun
				(_, #p_item{equip=E}, Acc2) ->
					mod_attr:sum([Acc2, E#p_equip.base, E#p_equip.rare1, E#p_equip.rare2, E#p_equip.rare3])
			end, #{}, Equips),

			Fin2 = case maps:get(?ATTR_ENCHANT, Fin1, 0) of
				0 ->
					Tmp3;
				V ->
					Tmp3#{
						?ATTR_HPMAX => round(maps:get(?ATTR_HPMAX, Tmp3, 0) * (1+?_per(V))),
						?ATTR_ATT   => round(maps:get(?ATTR_ATT, Tmp3, 0) * (1+?_per(V))),
						?ATTR_DEF   => round(maps:get(?ATTR_DEF, Tmp3, 0) * (1+?_per(V))),
						?ATTR_WRECK => round(maps:get(?ATTR_WRECK, Tmp3, 0) * (1+?_per(V)))
					}
			end,
			mod_attr:sum([Acc, Fin1, Fin2])
	end, #{}, Artis),
	mod_attr:add(Attrs1, Attrs2).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
keyfind(Key, N, List, Default) ->
	case lists:keyfind(Key, N, List) of
		false -> Default;
		Tuple -> Tuple
	end.

maybe_upgrade(Arti) ->
	#p_artifact{id=Aid, reinf_lv=Lv, reinf_exp=Exp} = Arti,
	case cfg_artifact_reinf:find(Aid, Lv+1) of
		#cfg_artifact_reinf{exp=MaxExp} when Exp >= MaxExp ->
			maybe_upgrade(Arti#p_artifact{reinf_lv=Lv+1, reinf_exp=Exp-MaxExp});
		_ ->
			Arti
	end.

calc_enchant_add([{ValMin, ValMax, AddMin, AddMax} | T], Val) ->
	case ValMin =< Val andalso Val =< ValMax of
		true  ->
			ut_rand:random(AddMin, AddMax);
		false ->
			calc_enchant_add(T, Val)
	end;
calc_enchant_add([], Val) ->
	?debug("calc add error: ~w", [Val]),
	0.
