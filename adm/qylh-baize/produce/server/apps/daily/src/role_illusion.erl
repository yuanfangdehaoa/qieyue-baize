%% @author rong
%% @doc
-module(role_illusion).

-include("role.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("daily.hrl").
-include("errno.hrl").

-export([sysopen/1, handle/2, add_exp/1, get_attr/1]).

sysopen(_RoleSt) ->
    R = role_data:get(?DB_ROLE_ILLUSION),
    if
        R#role_illusion.level == 0 ->
            Level = 1,
            #cfg_daily_show{group=ShowID} = cfg_daily_show:find(Level),
            role_data:set(R#role_illusion{level = Level, show_id = ShowID});
            % role_figure:update_illusion(#p_aspect{model=ShowID, show=true}, RoleSt);
        true ->
            ignore
    end.

handle(#m_daily_illusion_tos{}, RoleSt) ->
    #role_illusion{level=Level, exp=Exp, show_id=ShowID, show=Show} = role_data:get(?DB_ROLE_ILLUSION),
    ?ucast(#m_daily_illusion_toc{level=Level, exp=Exp, show_id=ShowID, show=Show});

handle(#m_daily_illusion_upgrade_tos{}, RoleSt) ->
    #role_illusion{level = Level, exp = Exp} = R = role_data:get(?DB_ROLE_ILLUSION),
    ?_check(cfg_daily_show:find(Level+1) =/= ?nil, ?ERR_DAILY_ILLUSION_MAX),
    ConfigFunc = fun(L) ->
        case cfg_daily_show:find(L+1) of
            ?nil ->
                max_level;
            #cfg_daily_show{activation=Need} ->
                Need
        end
    end,
    {Level2, Exp2} = upgrade(Level, Exp, ConfigFunc),
    #cfg_daily_show{group=Group} = cfg_daily_show:find(Level2),
    role_figure:update_illusion(#p_aspect{model=Group}, RoleSt),
    role_data:set(R#role_illusion{level=Level2, exp=Exp2, show_id=Group}),
    role_attr:recalc(?MODULE, RoleSt),
    ?ucast(#m_daily_illusion_upgrade_toc{level = Level2, exp = Exp2, show_id=Group});

handle(#m_daily_illusion_show_tos{show=Show}, RoleSt) ->
    R = role_data:get(?DB_ROLE_ILLUSION),
    role_data:set(R#role_illusion{show=Show}),
    role_figure:update_illusion(#p_aspect{show=Show}, RoleSt),
    ?ucast(#m_daily_illusion_show_toc{});

handle(#m_daily_illusion_select_tos{show_id=ShowID}, RoleSt) ->
    #role_illusion{level=Level} = R = role_data:get(?DB_ROLE_ILLUSION),
    #cfg_daily_show{group=MaxShowID} = cfg_daily_show:find(Level),
    ?_check(MaxShowID >= ShowID, ?ERR_GAME_BAD_ARGS),
    role_data:set(R#role_illusion{show_id=ShowID}),
    role_figure:update_illusion(#p_aspect{model=ShowID}, RoleSt),
    ?ucast(#m_daily_illusion_select_toc{show_id=ShowID}).

add_exp(Add) ->
    #role_illusion{exp = Exp} = R = role_data:get(?DB_ROLE_ILLUSION),
    role_data:set(R#role_illusion{exp = Exp+Add}).

upgrade(Level, Exp, ConfigFunc) ->
    case ConfigFunc(Level) of
        max_level ->
            {Level, 0};
        Need ->
            if
                Exp >= Need ->
                    % upgrade(Level+1, Exp-Need, ConfigFunc);
                    % 只升一级
                    {Level+1, Exp-Need};
                true ->
                    {Level, Exp}
            end
    end.

get_attr(_AttrType) ->
    #role_illusion{level = Level} = role_data:get(?DB_ROLE_ILLUSION),
    Conf = cfg_daily_show:find(Level),
    case Conf == ?nil of
        true  -> [];
        false -> Conf#cfg_daily_show.attr
    end.
