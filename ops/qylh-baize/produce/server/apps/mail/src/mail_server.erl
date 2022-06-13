%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(mail_server).

-behaviour(gen_server).

-include("game.hrl").
-include("item.hrl").
-include("mail.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("role.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([get_mails/1]).
-export([get_mail/2]).
-export([send/2]).
-export([read/2]).
-export([fetch/2]).
-export([delete/2]).

-define(SERVER, ?MODULE).

-define(ETS_MAILBOX, ets_mailbox).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%% 获取邮件列表
get_mails(RoleID) ->
    Mailbox = find_mailbox(RoleID),
    maps:values(Mailbox#mailbox.mails).

%% 获取邮件
get_mail(RoleID, MailID) ->
    Mailbox = find_mailbox(RoleID),
    find_mail(Mailbox, MailID).

%% 发送邮件
send(Attns, Opts) ->
    case cluster:is_local() of
        true ->
            gen_server:cast(?SERVER, {send, Attns, Opts});
        false ->
            [cluster:gen_cast_local(Attn, ?SERVER, {send,[Attn],Opts}) || Attn <- Attns]
    end.

%% 读取邮件
read(RoleID, Mail) ->
    gen_server:call(?SERVER, {read, RoleID, Mail}).

%% 提取附件
fetch(RoleID, Mail) ->
    gen_server:call(?SERVER, {fetch, RoleID, Mail}).

%% 删除邮件
delete(RoleID, MailIDs) ->
    gen_server:cast(?SERVER, {delete, RoleID, MailIDs}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
    process_flag(trap_exit, true),
    ets:new(?ETS_MAILBOX, [
        named_table, public, {keypos, #mailbox.owner}
    ]),
    loop_clean(),
    loop_dump(),
    {ok, undefined}.


handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(loop_clean, State) ->
    loop_clean(),
    ets:safe_fixtable(?ETS_MAILBOX, true),
    clear_mailbox( ets:first(?ETS_MAILBOX) ),
    ets:safe_fixtable(?ETS_MAILBOX, false),
    {noreply, State};

handle_info(loop_dump, State) ->
    loop_dump(),
    do_dump(),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    do_dump(),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 读取邮件
do_handle_call({read, RoleID, MailID}, _From, State) ->
    Mailbox = #mailbox{mails=Mails} = find_mailbox(RoleID),
    {ok, Mail} = find_mail(Mailbox, MailID),
    Mails2  = maps:put(MailID, Mail#mail{read=true}, Mails),
    ets:insert(?ETS_MAILBOX, Mailbox#mailbox{mails=Mails2}),
    {reply, {ok, Mail}, State};

%% 提取附件
do_handle_call({fetch, RoleID, Mail}, _From, State) ->
    Mailbox = #mailbox{mails=Mails} = find_mailbox(RoleID),
    Mail2   = Mail#mail{read=true, fetch=true},
    Mails2  = maps:put(Mail#mail.id, Mail2, Mails),
    ets:insert(?ETS_MAILBOX, Mailbox#mailbox{mails=Mails2}),
    {reply, ok, State};

do_handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.


%% 发送邮件
do_handle_cast({send, Attns, Opts}, State) when is_list(Attns) ->
    [send_mail(Attn, Opts) || Attn <- Attns],
    {noreply, State};

%% 删除邮件
do_handle_cast({delete, RoleID, MailIDs}, State) ->
    Mailbox = #mailbox{mails=Mails} = find_mailbox(RoleID),
    Mails2  = maps:filter(fun
        (MailID, _) ->
            not lists:member(MailID, MailIDs)
    end, Mails),
    ets:insert(?ETS_MAILBOX, Mailbox#mailbox{mails=Mails2}),
    {noreply, State};

do_handle_cast(_Msg, State) ->
    {noreply, State}.


loop_clean() ->
    erlang:send_after(timer:minutes(1), self(), loop_clean).

loop_dump() ->
    erlang:send_after(timer:minutes(15), self(), loop_dump).

do_dump() ->
    ets:foldl(fun
        (#mailbox{owner=Owner} = Mailbox,_) ->
            db:dirty_write(?DB_MAILBOX, Mailbox),
            case role:is_online(Owner) of
                false ->
                    case db:dirty_read(?DB_ROLE_INFO,Owner) of
                        [Role] ->
                            case ut_time:seconds() - Role#role_info.logout > (86400 * 7) of
                                true -> ets:delete(?ETS_MAILBOX,Owner);
                                _ -> ignore
                            end;
                        _ ->
                            ets:delete(?ETS_MAILBOX,Owner)
                    end;
                _ ->
                    ignore
            end
    end, [],?ETS_MAILBOX).

find_mailbox(Owner) ->
    case ets:lookup(?ETS_MAILBOX, Owner) of
        [M] ->
            M;
        []  ->
            Mailbox = case db:dirty_read(?DB_MAILBOX, Owner) of
                [M] -> M;
                []  -> #mailbox{owner=Owner, mailid=1, mails=#{}}
            end,
            ets:insert(?ETS_MAILBOX, Mailbox),
            Mailbox
    end.

find_mail(Mailbox, MailID) ->
    case maps:find(MailID, Mailbox#mailbox.mails) of
        {ok, Mail} ->
            {ok, Mail};
        error ->
            ?err(?ERR_MAIL_NOT_EXIST)
    end.

send_mail(Attn, Opts) ->
    Mailbox = find_mailbox(Attn),
    #mailbox{mailid=MailID, mails=Mails} = Mailbox,
    {ConfID, NewMail} = new_mail(Attn, MailID, Opts),
    Mails1  = maps:put(MailID, NewMail, Mails),
    Mails2  = case maps:size(Mails1) =< cfg_game:mail_amount() of
        true  ->
            Mails1;
        false ->
            DelID = find_oldest_mail(maps:values(Mails)),
            ?ucast(Attn, #m_mail_delete_toc{mail_ids=[DelID]}),
            maps:remove(DelID, Mails1)
    end,
    Mailbox2 = Mailbox#mailbox{mailid=MailID+1, mails=Mails2},
    ets:insert(?ETS_MAILBOX, Mailbox2),
    (ConfID == 0 orelse cfg_mail:is_log(ConfID)) andalso log_api:mail(Attn, NewMail),
    ?ucast(Attn, #m_mail_recv_toc{mail=mail_util:p_mail(NewMail)}).

new_mail(Attn, MailID, Opts) ->
    case Opts of
        {From, Type, ConfID, Title, Text, Items0, Last} ->
            {Items, Money} = mail_util:attachment(Attn, Items0);
        {From, Type, ConfID, Title, Text, Items, Money, Last} ->
            ok
    end,
    NTime = ut_time:seconds(),
    {ConfID, #mail{
        id     = MailID,
        from   = From,
        type   = Type,
        title  = Title,
        text   = Text,
        items  = Items,
        money  = Money,
        read   = false,
        send   = NTime,
        expire = NTime + Last * ?SECONDS_PER_DAY,
        fetch  = false
    }}.


%% 找出时间最久且无附件的邮件，如果都有附件，则找出时间最久的邮件
find_oldest_mail(Mails) ->
    Sorted = lists:keysort(#mail.send, Mails),
    case find_oldest_mail2(Sorted) of
        false  -> (hd(Sorted))#mail.id;
        MailID -> MailID
    end.

find_oldest_mail2([Mail | T]) ->
    case Mail#mail.items == [] orelse Mail#mail.fetch of
        true  -> Mail#mail.id;
        false -> find_oldest_mail2(T)
    end;
find_oldest_mail2([]) ->
    false.

clear_mailbox('$end_of_table') ->
    ok;
clear_mailbox(Owner)->
    NTime = ut_time:seconds(),
    [Mailbox] = ets:lookup(?ETS_MAILBOX, Owner),
    Mails2 = maps:filter(fun
        (_, Mail) ->
            Mail#mail.expire > NTime
    end, Mailbox#mailbox.mails),
    ets:insert(?ETS_MAILBOX, Mailbox#mailbox{mails=Mails2}),
    clear_mailbox( ets:next(?ETS_MAILBOX, Owner) ).
