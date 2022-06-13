-ifndef(MAIL_HRL).
-define(MAIL_HRL, ok).

%% 邮件
-record(mail, {
      id     :: integer() % 邮件id
    , from   :: string()  % 发件人名字
    , type   :: integer() % 邮件类型
    , title  :: string()  % 邮件标题
    , text   :: string()  % 文本内容
    , items  :: list()    % 附件列表 [#p_item{}]
    , money  :: map()     % 货币
    , send   :: integer() % 发送时间
    , expire :: integer() % 过期时间
    , read   :: boolean() % 是否已读
    , fetch  :: boolean() % 是否已领取附件
}).

-endif.