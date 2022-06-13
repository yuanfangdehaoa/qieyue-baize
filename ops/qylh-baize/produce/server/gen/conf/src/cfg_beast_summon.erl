% Automatically generated, do not edit
-module(cfg_beast_summon).

-compile([export_all]).
-compile(nowarn_export_all).

-include("beast.hrl").

find(4) -> #cfg_beast_summon{
    restrict = [{level,380}],
    cost     = [{30015,2}]
};
find(5) -> #cfg_beast_summon{
    restrict = [{level,430}],
    cost     = [{30015,3}]
};
find(6) -> #cfg_beast_summon{
    restrict = [{level,450}],
    cost     = [{30015,5}]
};
find(7) -> #cfg_beast_summon{
    restrict = [{level,470}],
    cost     = [{30015,8}]
};
find(8) -> #cfg_beast_summon{
    restrict = [{level,490}],
    cost     = [{30015,10}]
};
find(9) -> #cfg_beast_summon{
    restrict = [{level,510}],
    cost     = [{30015,12}]
};
find(10) -> #cfg_beast_summon{
    restrict = [{level,530}],
    cost     = [{30015,15}]
};
find(_) -> undefined.
