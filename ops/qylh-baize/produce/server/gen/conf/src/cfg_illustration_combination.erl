% Automatically generated, do not edit
-module(cfg_illustration_combination).

-compile([export_all]).
-compile(nowarn_export_all).

-include("illustration.hrl").

find(1) -> #cfg_illustration_combination{
    illustrations = [8880204,8880203,8880202,8880201], 
    attr          = [{4,2362},{6,1012},{1404,200}]
};
find(2) -> #cfg_illustration_combination{
    illustrations = [8880501,8880502,8880503], 
    attr          = [{2,18918},{5,404},{1102,100}]
};
find(3) -> #cfg_illustration_combination{
    illustrations = [8880104,8880103,8880102,8880101], 
    attr          = [{4,2362},{6,1012},{1404,200}]
};
find(4) -> #cfg_illustration_combination{
    illustrations = [8880301,8880302,8880303,8880304], 
    attr          = [{2,18918},{5,404},{1102,100}]
};
find(5) -> #cfg_illustration_combination{
    illustrations = [8880401,8880402,8880403,8880404], 
    attr          = [{4,2362},{6,1012},{1404,200}]
};
find(6) -> #cfg_illustration_combination{
    illustrations = [8880601,8880602,8880603,8880604], 
    attr          = [{2,18918},{5,404},{1102,100}]
};
find(7) -> #cfg_illustration_combination{
    illustrations = [8881001,8881002,8881003,8881004], 
    attr          = [{4,2362},{6,1012},{1404,200}]
};
find(_) -> undefined.

list() -> [5,6,7,1,2,3,4].
