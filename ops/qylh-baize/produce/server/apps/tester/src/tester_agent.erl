%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(tester_agent).

-behaviour(gen_server).

-include("game.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start/2]).

-define(SERVER, ?MODULE).

-record(state, {
	  id
	, prefix
	, sock
	, token
	, role
	, scene
	, actor
	, around
	, tasks
	, skills
}).


-compile([export_all]).
-compile(nowarn_export_all).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start(TesterID, Prefix) ->
    RegName = ut_conv:to_atom( lists:concat(["tester-", TesterID]) ),
	gen_server:start({local,RegName}, ?MODULE, {TesterID,Prefix}, []).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({TesterID,Prefix}) ->
	process_flag(trap_exit, true),
	Host = tester:host(),
	Port = tester:port(),
	{ok, Sock} = gen_tcp:connect(Host, Port, [{packet,4}, binary]),
	erlang:send(self(), start),
	{ok, #state{id=TesterID, prefix=Prefix, sock=Sock}}.

handle_call(_Request, _From, State) ->
	{reply, {error, unknown_call}, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.


handle_info({tcp, _, Bin}, State) ->
    {ok, MsgID, Toc} = decode(Bin),
    try
        do_handle(MsgID, Toc, State)
    of
        {ok, Tos, State2}  ->
            send_server(State#state.sock, Tos),
            {noreply, State2};
        {ok, Tos} ->
            send_server(State#state.sock, Tos),
            {noreply, State};
        Result ->
            Result
    catch
        Class:Reason:Stacktrace ->
        	io:format("Stacktrace:~p", [{Class, Reason, Stacktrace}]),
            {noreply, State}
    end;

handle_info(action, State) ->
	ActionList = [
		fun() -> do_cheat("level-1", State) end,
		fun() ->
			send_server(State#state.sock, #m_scene_dest_tos{
				dest  = #p_coord{x=1418, y=4586},
				dir   = 0,
				state = 0
			})
		end
	],
	Action = ut_rand:choose(ActionList),
	Action(),
	% erlang:send_after(timer:seconds(ut_rand:random(3,7)), self(), action),
	% Action = ut_rand:weight([{State#state.type,90}, {change,10}]),
	% do_action(Action, State),
	{noreply, State};

handle_info(start, State) ->
	Account = lists:concat([State#state.prefix, State#state.id]),
	io:format("start: ~s~n", [Account]),
	Tos = #m_login_verify_tos{
		platform = "xingwan",
		gamechan = "develop",
		account  = Account,
		token    = "token",
		args     = #{}
	},
	send_server(State#state.sock, Tos),
	{noreply, State};

handle_info(_Info, State) ->
	{noreply, State}.

terminate(Reason, State) ->
	tester_manager:ret_id(State#state.id),
	io:format("terminate:~p", [Reason]),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle(?LOGIN_VERIFY, Toc, State) ->
	#m_login_verify_toc{roles=Roles} = Toc,
	case Roles == [] of
		true  ->
			Name = lists:concat([State#state.prefix, State#state.id]),
			Tos  = #m_login_create_tos{career=1, gender=1, name=Name},
			{ok, Tos};
		false ->
			#p_role_base{id=RoleID} = ut_rand:choose(Roles),
			Tos = #m_login_enter_tos{role_id=RoleID},
			{ok, Tos, State#state{role=RoleID}}
	end;
do_handle(?LOGIN_CREATE, Toc, _State) ->
	#m_login_create_toc{role_id=RoleID} = Toc,
	{ok, #m_login_enter_tos{role_id=RoleID}};
do_handle(?LOGIN_ENTER, Toc, State) ->
	#m_login_enter_toc{token=Token} = Toc,
	{ok, #m_role_detail_tos{}, State#state{token=Token}};
	% {noreply, State#state{token=Token}};
do_handle(?ROLE_DETAIL, Toc, State) ->
	#m_role_detail_toc{role=Role} = Toc,
	% case Role#p_role_info.level == 1 of
	% 	true  ->
	% 		do_cheat("rich", State),
	% 		do_cheat("vip-12", State),
	% 		do_cheat("level-1", State);
	% 	false ->
	% 		ignore
	% end,
	% send_server(State#state.sock, #m_task_list_tos{}),
	% send_server(State#state.sock, #m_skill_list_tos{}),
	{noreply, State#state{role=Role}};
do_handle(?SCENE_CHANGE, Toc, State) ->
	#m_scene_change_toc{scene=SceneID, actor=Actor, actors=Actors} = Toc,
	timer:send_interval(timer:seconds(2), action),
	{noreply, State#state{scene=SceneID, actor=Actor, around=Actors}};
% do_handle(?TASK_LIST, Toc, State) ->
% 	#m_task_list_toc{tasks=Tasks} = Toc,
% 	{noreply, State#state{tasks=Tasks}};
% do_handle(?SKILL_LIST, Toc, State) ->
% 	#m_skill_list_toc{skills=Skills} = Toc,
% 	erlang:send(self(), action),
% 	{noreply, State#state{skills=Skills}};
do_handle(_MsgID, _Toc, State) ->
	{noreply, State}.


do_action(task, _State) ->
	ok;
do_action(fight, State) ->
	#state{actor=Self, skills=Skills, around=Around} = State,
	SkillID = select_skill(Skills),
	case SkillID > 0 of
		true  ->
			case select_defer(Around, Self, SkillID) of
				?nil  ->
					ignore;
				Defer ->
					Dir = scene_util:calc_radian(
						Defer#p_actor.coord, Self#p_actor.coord
					),
					Tos = #m_fight_attack_tos{
						unit  = ?ATTACK_UNIT_ROLE,
						skill = SkillID,
						dir   = Dir,
						defid = Defer#p_actor.uid,
						coord = Defer#p_actor.coord,
						seq   = 0
					},
					send_server(State#state.sock, Tos)
			end;
		false ->
			ignore
	end;
do_action(move, _State) ->
	ok;
do_action(chat, State) ->
	Tos = #m_chat_channel_tos{
		channel_id = ut_rand:choose([
			?CHAT_CHANNEL_WORLD,
			?CHAT_CHANNEL_SCENE
		]),
		type_id = 0,
		content = ut_rand:choose([
			"赶快写文档啊……",
			"赶快做功能啊……",
			"赶快测试啊……",
			"赶快画UI啊……"
		])
	},
	send_server(State#state.sock, Tos);
do_action(team, _State) ->
	ok;
do_action(change, State) ->
	Scenes  = cfg_scene:scenes(?SCENE_TYPE_FIELD),
	SceneID = ut_rand:choose(Scenes),
	Creeps  = scene_config:creeps(SceneID),
	case Creeps == [] of
		true  ->
			ignore;
		false ->
			{_, Coord} = ut_rand:choose(Creeps),
			Tos = #m_scene_change_tos{
				scene = SceneID,
				type  = ?SCENE_CHANGE_SHOES,
				coord = Coord
			},
			send_server(State#state.sock, Tos)
	end;
do_action(_Action, _State) ->
	ok.

do_cheat(Cmd, State) ->
	Tos = #m_game_cheat_tos{cmd=Cmd},
	send_server(State#state.sock, Tos).


select_skill(Skills) ->
	Millis  = ut_time:milliseconds(),
	Skills1 = lists:keysort(#p_skill.cd, Skills),
	Skills2 = lists:reverse(Skills1),
	select_skill2(Skills2, Millis).

select_skill2([Skill | T], Millis) ->
	case Millis >= Skill#p_skill.cd of
		true  -> Skill#p_skill.id;
		false -> select_skill2(T, Millis)
	end;
select_skill2([], _Millis) ->
	0.

select_defer(Around, Actor, SkillID) ->
	#cfg_skill_level{dist=Dist} = cfg_skill_level:find(SkillID, 1),
	select_defer2(Around, Actor, Dist).

select_defer2([Defer | T], Atker, Dist1) ->
	Dist2 = scene_util:calc_distance(Atker#p_actor.coord, Defer#p_actor.coord),
	case Dist2 =< Dist1 of
		true  -> Defer;
		false -> select_defer2(T, Atker, Dist1)
	end;
select_defer2([], _Atker, _Dist) ->
	?nil.




encode(Tos) ->
	{_, MsgID}  = proto:get_msgid(element(1, Tos)),
	{_, Mod, _} = proto:get_tos(MsgID),
	Bin = Mod:encode_msg(Tos),
	{ok, <<MsgID:32, Bin/binary>>}.

decode(Bin) ->
	<<MsgID:32, _:32, Rem/binary>> = Bin,
	{_, Mod, Rec} = proto:get_toc(MsgID),
	Toc = Mod:decode_msg(Rem, Rec),
	{ok, MsgID, Toc}.

send_server(Sock, Tos) ->
	{ok, Bin} = encode(Tos),
	gen_tcp:send(Sock, Bin).
