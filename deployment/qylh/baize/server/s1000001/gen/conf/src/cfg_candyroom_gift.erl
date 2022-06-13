% Automatically generated, do not edit
-module(cfg_candyroom_gift).

-compile([export_all]).
-compile(nowarn_export_all).

-include("candyroom.hrl").

find(1) -> #cfg_candyroom_gift{name="甜甜圈", pop=5, msg_no=160401};
find(2) -> #cfg_candyroom_gift{name="棒棒糖", pop=5, msg_no=160402};
find(3) -> #cfg_candyroom_gift{name="巧克力", pop=5, msg_no=160403};
find(4) -> #cfg_candyroom_gift{name="大雪糕", pop=5, msg_no=160404};
find(_) -> undefined.