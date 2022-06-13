% Automatically generated, do not edit
-module(cfg_mchunt).

-compile([export_all]).
-compile(nowarn_export_all).

cost(1) -> [{90010015,100}];
cost(2) -> [{90010015,1000}];
cost(_) -> [].

reward(1) -> [{90010013,0,1,2},{90010014,80,5,5}];
reward(2) -> [{90010013,0,10,20},{90010014,80,50,50}];
reward(_) -> [].
