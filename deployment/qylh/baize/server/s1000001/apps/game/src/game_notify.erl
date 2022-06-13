%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_notify).

-include("proto.hrl").

%% API
-export([notify/2]).
-export([notify/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
notify(MsgNo, Args) ->
	notify(online_server:get_roles(), MsgNo, Args).

notify(SendTo, MsgNo, Args) when is_list(SendTo) ->
	game_pool:bc_to_gate(SendTo, #m_game_notify_toc{
	    msgno = MsgNo,
	    args  = [p_msgno(Arg) || Arg<-Args]
	});
notify(SendTo, MsgNo, Args) ->
	gateway:send(SendTo, #m_game_notify_toc{
	    msgno = MsgNo,
	    args  = [p_msgno(Arg) || Arg<-Args]
	}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
p_msgno({item, Items}) ->
	#p_msgno{items=Items};
p_msgno({pitem, Items}) ->
	#p_msgno{pitems=Items};
p_msgno({role, RoleID, RoleName}) ->
	#p_msgno{props=#{"rolename"=>io_lib:format("~w|~ts", [RoleID, RoleName])}};
p_msgno({color, Target, Color}) ->
	#p_msgno{props=#{"general"=>ut_color:format(Target, Color)}};
p_msgno({list, Props}) ->
	p_msgno2(Props, #p_msgno{});
p_msgno(Prop) ->
	p_msgno2([Prop], #p_msgno{}).

p_msgno2([{Key, Val} | T], Msg) ->
	Key2 = ut_conv:to_list(Key),
	Val2 = ut_conv:to_list(Val),
	Msg2 = Msg#p_msgno{props=maps:put(Key2, Val2, Msg#p_msgno.props)},
	p_msgno2(T, Msg2);
p_msgno2([Val | T], Msg) ->
	Val2 = ut_conv:to_list(Val),
	Msg2 = Msg#p_msgno{props=maps:put("general", Val2, Msg#p_msgno.props)},
	p_msgno2(T, Msg2);
p_msgno2([], Msg) ->
	Msg.
