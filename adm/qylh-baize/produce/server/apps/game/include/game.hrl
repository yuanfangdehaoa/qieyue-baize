-ifndef(GAME_HRL).
-define(GAME_HRL, ok).

-type error() :: {error, Errno :: integer(), Args :: list()}.

-record(r_tab, {name, rec, opts, init}).

%% 合服数据
-record(merge, {
      time  = 0  % 合服时间
    , suids = [] % 合服列表 [SUID]
}).

-define(SERVER_TYPE_CENTER, center).
-define(SERVER_TYPE_LOCAL, server).
-define(SERVER_TYPE_CROSS, cross).

-define(SECONDS_PER_DAY, 86400).
-define(SECONDS_PER_HOUR, 3600).
-define(SECONDS_PER_MINUTE, 60).

-define(nil, undefined).
-define(nil_guild,'guild-0').

-define(err(Errno), {error, Errno, []}).
-define(err(Errno, Args), {error, Errno, [ut_conv:to_list(A) || A <- Args]}).

% 万分之
-define(PER_10000, 10000).
-define(_per(Val), ((Val) / ?PER_10000)).

% 位设置
-define(_bis(X, Mask), (X bor Mask)).
% 位清除
-define(_bic(X, Mask), (X band (bnot Mask))).

-define(_if(Cond, Expr),
    (Cond) andalso Expr).
-define(_if(Expr, Expr1, Expr2),
    case (Expr) of
        true  -> Expr1;
        false -> Expr2
    end).

-define(_check(Expr, Errno),
    ?_check(Expr, Errno, [])).
-define(_check(Expr, Errno, Args),
    case (Expr) of
        true  -> ok;
        false -> throw({error, Errno, [ut_conv:to_list(AA) || AA <- Args]})
    end).

-define(_match(Match, Expr, Errno),
    case (Expr) of
        Match -> ok;
        _ -> throw({error, Errno, []})
    end).

%% 单播
-define(ucast(Toc),
    gateway:send(RoleSt#role_st.gate, Toc)).
-define(ucast(SendTo, Toc),
    gateway:send(SendTo, Toc)).

%% 广播
-define(bcast(Toc),
    game_pool:bc_to_gate(online_server:get_roles(), Toc)).
-define(bcast(RoleIDs, Toc),
    game_pool:bc_to_gate(RoleIDs, Toc)).
-define(bcast(RoleIDs, Except, Toc),
    game_pool:bc_to_gate(lists:delete(Except, RoleIDs), Toc)).

%% 系统通知
-define(notify(MsgNo),
    ?notify(online_server:get_roles(), MsgNo, [])).
-define(notify(MsgNo, Args),
    ?notify(online_server:get_roles(), MsgNo, Args)).
-define(notify(SendTo, MsgNo, Args),
    game_notify:notify(SendTo, MsgNo, Args)).


-define(debug(Format),
    ?debug(Format, [])).
-define(debug(Format, Args),
    lager:debug(Format, Args)).
-define(debug(Cond, Format, Args),
    ?_if(Cond, ?debug(Format, Args))).

-define(info(Format),
    ?info(Format, [])).
-define(info(Format, Args),
    lager:info(Format, Args)).

-define(notice(Format),
    ?notice(Format, [])).
-define(notice(Format, Args),
    lager:notice(Format, Args)).

-define(warn(Format),
    ?warn(Format, [])).
-define(warn(Format, Args),
    lager:warning(Format, Args)).

-define(error(Format),
    ?error(Format, [])).
-define(error(Format, Args),
    lager:error(Format, Args)).

-define(fatal(Format),
    ?fatal(Format, [])).
-define(fatal(Format, Args),
    lager:critical(Format, Args)).

-define(stacktrace(Class, Reason, Stacktrace),
    lager:error("stacktrace:~p", [lager:pr_stacktrace(Stacktrace, {Class, Reason})])).

-define(terminate(Reason),
    case Reason of
        normal ->
            ignore;
        shutdown ->
            ignore;
        {shutdown, _} ->
            ignore;
        _ ->
            lager:error("terminate: ~p", [Reason])
    end).

-define(try_handle_call(Expr, State),
    try
        (Expr)
    catch
        throw:Error ->
            {reply, Error, State};
        error:{badmatch, {error, _, _} = Error} ->
            {reply, Error, State};
        Class:Reason:Stacktrace ->
            ?stacktrace(Class, Reason, Stacktrace),
            {reply, ?err(?ERR_GAME_SYS_ERROR), State}
    end
).

-define(try_handle_cast(Expr, State),
    try
        (Expr)
    catch Class:Reason:Stacktrace ->
        ?stacktrace(Class, Reason, Stacktrace),
        {noreply, State}
    end
).

-define(try_handle_info(Expr, State),
    try
        (Expr)
    catch Class:Reason:Stacktrace ->
        ?stacktrace(Class, Reason, Stacktrace),
        {noreply, State}
    end
).

-endif.