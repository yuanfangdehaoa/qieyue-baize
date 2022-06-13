% Automatically generated, do not edit
-module(cfg_totems_summon).

-compile([export_all]).
-compile(nowarn_export_all).

-include("totem.hrl").

find(4) -> #cfg_totem_summon{
    restrict = [{level,450}],
    cost     = [{300006,2}]
};
find(5) -> #cfg_totem_summon{
    restrict = [{level,470}],
    cost     = [{300006,3}]
};
find(6) -> #cfg_totem_summon{
    restrict = [{level,490}],
    cost     = [{300006,5}]
};
find(7) -> #cfg_totem_summon{
    restrict = [{level,510}],
    cost     = [{300006,8}]
};
find(8) -> #cfg_totem_summon{
    restrict = [{level,525}],
    cost     = [{300006,10}]
};
find(9) -> #cfg_totem_summon{
    restrict = [{level,540}],
    cost     = [{300006,12}]
};
find(10) -> #cfg_totem_summon{
    restrict = [{level,555}],
    cost     = [{300006,15}]
};
find(_) -> undefined.
