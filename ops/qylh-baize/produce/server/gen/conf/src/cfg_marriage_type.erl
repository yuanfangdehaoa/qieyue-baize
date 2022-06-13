% Automatically generated, do not edit
-module(cfg_marriage_type).

-compile([export_all]).
-compile(nowarn_export_all).

-include("marriage.hrl").

find(1) -> #cfg_marriage_type{
    name    = "简约婚礼", 
    reward  = [{11141,2,1}],
    title   = 46006,
    cost    = [{90010004,9900}],
    wcount  = 1
};
find(2) -> #cfg_marriage_type{
    name    = "豪华婚礼", 
    reward  = [{15094,1,1},{11141,4,1}],
    title   = 46007,
    cost    = [{90010003,26000}],
    wcount  = 1
};
find(3) -> #cfg_marriage_type{
    name    = "奢华婚礼", 
    reward  = [{15094,1,1},{43006,1,1},{11141,8,1}],
    title   = 46008,
    cost    = [{90010003,65700}],
    wcount  = 1
};
find(_) -> undefined.
