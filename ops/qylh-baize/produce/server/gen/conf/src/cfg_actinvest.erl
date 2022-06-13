% Automatically generated, do not edit
-module(cfg_actinvest).

-compile([export_all]).
-compile(nowarn_export_all).

-include("actinvest.hrl").

find(1001) -> #cfg_actinvest{name="图鉴投资", cycle=opdays, days=[], time=[{{6,{0,0,0}},{12,{23,59,59}}}], pay=[{90010003,58800}], panel="960@1@1"};
find(1002) -> #cfg_actinvest{name="圣痕投资", cycle=opdays, days=[], time=[{{6,{0,0,0}},{12,{23,59,59}}}], pay=[{90010003,138000}], panel="960@1@2"};
find(1003) -> #cfg_actinvest{name="魂卡投资", cycle=opdays, days=[], time=[{{6,{0,0,0}},{12,{23,59,59}}}], pay=[{90010003,188000}], panel="960@1@3"};
find(_) -> undefined.

all() -> [1001,1002,1003].
