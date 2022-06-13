% Automatically generated, do not edit
-module(cfg_skill_get).

-compile([export_all]).
-compile(nowarn_export_all).

-include("skill.hrl").

find(1, 6) -> [101005];
find(1, 12) -> [101006];
find(1, 17) -> [101007];
find(1, 36) -> [101008];
find(1, 24) -> [205001];
find(2, 6) -> [201005];
find(2, 12) -> [201006];
find(2, 17) -> [201007];
find(2, 36) -> [201008];
find(2, 24) -> [205001];
find(1, 1) -> [101001,101002,101003,101004];
find(2, 1) -> [201001,201002,201003,201004];
find(_, _) -> [].

skills(1) -> [6,12,17,36,24,1];
skills(2) -> [24,1,6,12,17,36];
skills(_) -> [].