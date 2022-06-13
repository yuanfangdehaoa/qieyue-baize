%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(mail_handler).

-include("bag.hrl").
-include("role.hrl").
-include("game.hrl").
-include("mail.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).

-define(PAGE_SIZE, 20).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 邮件信息
handle(?MAIL_INFO, _Tos, RoleSt) ->
    Mails = mail_server:get_mails(RoleSt#role_st.role),
    AnyUnread = lists:any(fun
        (Mail) ->
            (not Mail#mail.read) orelse
            (Mail#mail.items /= [] andalso not Mail#mail.fetch)
    end, Mails),
    ?ucast(#m_mail_info_toc{unread=AnyUnread});

%% 邮件列表
handle(?MAIL_LIST, _Tos, RoleSt) ->
    Mails  = mail_server:get_mails(RoleSt#role_st.role),
    Mails2 = [mail_util:p_mail(Mail) || Mail <- Mails],
    ?ucast(#m_mail_list_toc{mails=Mails2});

%% 读取邮件
handle(?MAIL_READ, Tos, RoleSt) ->
    #m_mail_read_tos{mail_id=MailID} = Tos,
    {ok, Mail} = mail_server:read(RoleSt#role_st.role, MailID),
    ?ucast(#m_mail_read_toc{
        mail_id = MailID,
        text    = Mail#mail.text,
        items   = [item_util:p_item(Item) || Item <- Mail#mail.items],
        money   = Mail#mail.money
    });

%% 提取附件
handle(?MAIL_FETCH, Tos, RoleSt) ->
    #m_mail_fetch_tos{mail_id=MailID} = Tos,
    #role_st{role=RoleID} = RoleSt,
    case MailID of
        0 ->
            lists:foreach(fun
                (Mail) ->
                    do_fetch(Mail, RoleSt)
            end, mail_server:get_mails(RoleID));
        _ ->
            {ok, Mail} = mail_server:get_mail(RoleID, MailID),
            do_fetch(Mail, RoleSt)
    end;


%% 删除邮件
handle(?MAIL_DELETE, Tos, RoleSt = #role_st{role=RoleID}) ->
    #m_mail_delete_tos{mail_ids=MailIDs} = Tos,
    ?_check(ut_misc:is_unique(MailIDs), ?ERR_GAME_BAD_ARGS),
    Mails = mail_server:get_mails(RoleID),
    check_delete(Mails, MailIDs),
    mail_server:delete(RoleID, MailIDs),
    ?ucast(#m_mail_delete_toc{mail_ids = MailIDs}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_delete(Mails, [MailID | T]) ->
    Mail = lists:keyfind(MailID, #mail.id, Mails),
    ?_check(Mail /= false, ?ERR_MAIL_NOT_EXIST),
    #mail{fetch=Fetch, items=Items, money=Money} = Mail,
    CanDelete = Items == [] andalso Money == #{} orelse Fetch,
    ?_check(CanDelete, ?ERR_MAIL_HAS_ITEMS),
    check_delete(Mails, T);
check_delete(_, []) ->
    ok.

do_fetch(Mail, RoleSt) ->
    #mail{id=MailID, type=Type, fetch=Fetch, items=Items, money=Money} = Mail,
    ?_check(not Fetch, ?ERR_MAIL_HAD_FETCH),
    ?_check(Items /= [] orelse Money /= #{}, ?ERR_MAIL_NO_ITEMS),
    Gain  = maps:to_list(Money) ++ Items,
    LogID = ?_if(Type == ?MAIL_TYPE_REFUND, ?LOG_PAY_REFUND, ?LOG_MAIL_FETCH),
    role_bag:gain(Gain, LogID, RoleSt),
    mail_server:fetch(RoleSt#role_st.role, Mail),
    ?ucast(#m_mail_fetch_toc{mail_id=[MailID]}).
