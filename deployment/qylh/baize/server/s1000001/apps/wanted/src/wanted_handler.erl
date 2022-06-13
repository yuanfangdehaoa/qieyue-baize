%% @author rong
%% @doc
-module(wanted_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("wanted.hrl").
-include("enum.hrl").

-export([handle/3]).

handle(?WANTED_INFO, _Tos, RoleSt) ->
    #role_wanted{task=Task} = role_data:get(?DB_ROLE_WANTED),
    ?ucast(#m_wanted_info_toc{task=Task});

handle(?WANTED_REWARD, _Tos, RoleSt) ->
    #role_wanted{task=Task} = RoleWanted = role_data:get(?DB_ROLE_WANTED),
    ?_check(Task =/= ?nil, ?ERR_WANTED_NO_REWARD),
    Task#p_wanted_task.state == ?WANTED_TASK_STATE_UNDONE
        andalso throw(?err(?ERR_WANTED_NOT_FINISH)),
    Task#p_wanted_task.state == ?WANTED_TASK_STATE_REWARD 
        andalso throw(?err(?ERR_WANTED_ALREADY_REWARD)),
    #cfg_wanted{skill=SkillID} = cfg_wanted:find(Task#p_wanted_task.id),
    role_skill:active(SkillID, RoleSt),
    case role_wanted:trigger_next(Task) of
        ?nil ->
            Task2 = Task#p_wanted_task{state=?WANTED_TASK_STATE_REWARD},
            role_data:set(RoleWanted#role_wanted{task=Task2}),
            ?ucast(#m_wanted_reward_toc{next=Task2});
        Next ->
            role_data:set(RoleWanted#role_wanted{task=Next}),
            role_wanted:add_listener(Next, RoleSt),
            ?ucast(#m_wanted_reward_toc{next=Next})
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

