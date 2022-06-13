% Automatically generated, do not edit
-module(cfg_yunying_gift).

-compile([export_all]).
-compile(nowarn_export_all).

-include("yunying.hrl").

find(100401) -> #cfg_yunying_gift{
    id          = 100401,
    refund_time = 5,
    cycle       = opdays,
    days        = [],
    time        = [{{1,{0,0,0}},{7,{23,59,59}}}],
    desc        = "升级大礼"
};
find(100402) -> #cfg_yunying_gift{
    id          = 100402,
    refund_time = 86400,
    cycle       = opdays,
    days        = [],
    time        = [{{1,{0,0,0}},{7,{23,59,59}}}],
    desc        = "宠物觉醒"
};
find(100403) -> #cfg_yunying_gift{
    id          = 100403,
    refund_time = 259200,
    cycle       = opdays,
    days        = [],
    time        = [{{1,{0,0,0}},{7,{23,59,59}}}],
    desc        = "海洋之星"
};
find(100404) -> #cfg_yunying_gift{
    id          = 100404,
    refund_time = 432000,
    cycle       = opdays,
    days        = [],
    time        = [{{1,{0,0,0}},{7,{23,59,59}}}],
    desc        = "经验魂卡"
};
find(_) -> undefined.

all() -> [100403,100404,100401,100402].
