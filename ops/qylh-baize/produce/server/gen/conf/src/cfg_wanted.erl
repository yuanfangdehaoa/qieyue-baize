% Automatically generated, do not edit
-module(cfg_wanted).

-compile([export_all]).
-compile(nowarn_export_all).

-include("wanted.hrl").

find(1) -> #cfg_wanted{target = {9,303,[],5}, skill = 400601};
find(2) -> #cfg_wanted{target = {3,3,[{boss_type,1},{level,130}],1}, skill = 400600};
find(3) -> #cfg_wanted{target = {3,3,[{boss_type,1},{level,140}],1}, skill = 400602};
find(4) -> #cfg_wanted{target = {3,3,[{boss_type,1},{level,150}],1}, skill = 400605};
find(5) -> #cfg_wanted{target = {3,3,[{boss_type,1},{level,190}],1}, skill = 400606};
find(6) -> #cfg_wanted{target = {3,3,[{boss_type,1},{level,215}],1}, skill = 400603};
find(7) -> #cfg_wanted{target = {3,3,[{boss_type,1},{level,230}],1}, skill = 400607};
find(8) -> #cfg_wanted{target = {3,3,[{boss_type,1},{level,240}],1}, skill = 400608};
find(9) -> #cfg_wanted{target = {3,3,[{boss_type,1},{level,255}],1}, skill = 400604};
find(10) -> #cfg_wanted{target = {3,3,[{boss_type,1},{level,280}],1}, skill = 400609};
find(11) -> #cfg_wanted{target = {3,3,[{boss_type,1},{level,300}],1}, skill = 400610};
find(_) -> undefined.

all() -> [1,2,3,4,5,6,7,8,9,10,11].
