%% @author rong
%% @doc
-module(yylogin_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("enum.hrl").
-include("msgno.hrl").
-include("item.hrl").

-export([hook_reset/3, handle/3]).

hook_reset(_DoW, _Hour, RoleSt) ->
    #role_yylogin{days=Days} = Login = role_data:get(?DB_ROLE_YYLOGIN),
    role_data:set(Login#role_yylogin{days=Days+1}),
    handle(?YYLOGIN_INFO, ?nil, RoleSt).

handle(?YYLOGIN_INFO, _Tos, RoleSt) ->
    #role_yylogin{days=Days, list=List} = role_data:get(?DB_ROLE_YYLOGIN),
    ?ucast(#m_yylogin_info_toc{days=Days, list=List});

handle(?YYLOGIN_REWARD, Tos, RoleSt) ->
    #m_yylogin_reward_tos{day = Day} = Tos,
    #role_yylogin{days=Days, list=List} = Login = role_data:get(?DB_ROLE_YYLOGIN),
    ?_check(not lists:member(Day, List), ?ERR_YYLOGIN_ALREADY_REWARD),
    ?_check(Days >= Day, ?ERR_YYLOGIN_DAY_WRONG),
    ?_check(Day =< cfg_yylogin:max(), ?ERR_YYLOGIN_DAY_MAX),
    case cfg_yylogin:find(Day) of
        Gain when is_list(Gain) ->
            Succ = fun() ->
                role_data:set(Login#role_yylogin{list=[Day|List]}),
                ?ucast(#m_yylogin_reward_toc{day=Day}),
                notify_reward(Day, Gain, RoleSt)
            end,
            role_bag:gain(Gain, ?LOG_YYLOGIN_REWARD, Succ, RoleSt);
        _ ->
            ?debug("======yylogin no reward ~w", [Day]),
            throw(?err(?ERR_GAME_BAD_ARGS, [?YYLOGIN_REWARD]))
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
notify_reward(Day, Gain, _RoleSt) ->
    #role_info{id=RoleID, name=RoleName, gender=Gender} = role_data:get(?DB_ROLE_INFO),
    I = hd(Gain),
    ItemID = case element(1, I) of
        ItemID0 when is_integer(ItemID0) -> ItemID0;
        GenderList when is_list(GenderList) -> lists:nth(Gender, GenderList)
    end,
    Num = element(2, I),
    #cfg_item{name=Name, color=Color} = cfg_item:find(ItemID),
    NoticeItem = ut_color:format(Name ++ ?_if(Num > 1, "*"++ut_conv:to_list(Num), ""), Color),
    ?notify(?MSG_YYLOGIN_REWARD, [{role,RoleID,RoleName}, Day, NoticeItem]).
