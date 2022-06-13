% Automatically generated, do not edit
-module(cfg_actpay).

-compile([export_all]).
-compile(nowarn_export_all).

-include("actpay.hrl").

find(1) -> #cfg_actpay{opdays=8, pay=5000};
find(_) -> undefined.

all() -> [1].
