% Automatically generated, do not edit
-module(cfg_weekly).

-compile([export_all]).
-compile(nowarn_export_all).

-include("weekly.hrl").

find(1000) -> #cfg_weekly{count = 3, target = [], reward = [{100001,1},{100002,1},{100003,1},{90010017,5}]};
find(1001) -> #cfg_weekly{count = 3, target = [], reward = [{100001,1},{100002,1},{100003,1},{90010017,6}]};
find(1002) -> #cfg_weekly{count = 3, target = [], reward = [{100001,1},{100002,1},{100003,1},{90010017,7}]};
find(1) -> #cfg_weekly{count = 20, target = [{7,92}], reward = [{100001,1},{100002,1},{100003,1},{90010017,8}]};
find(2) -> #cfg_weekly{count = 10, target = [{13,0}], reward = [{100001,1},{100002,1},{100003,1},{90010017,9}]};
find(3) -> #cfg_weekly{count = 5, target = [{8,0}], reward = [{100001,1},{100002,1},{100003,1},{90010017,10}]};
find(4) -> #cfg_weekly{count = 70, target = [{7,93}], reward = [{100001,1},{100002,1},{100003,1},{90010017,11}]};
find(5) -> #cfg_weekly{count = 1, target = [{9,303}], reward = [{100001,1},{100002,1},{100003,1},{90010017,12}]};
find(6) -> #cfg_weekly{count = 1, target = [{10,301}], reward = [{100001,1},{100002,1},{100003,1},{90010017,13}]};
find(7) -> #cfg_weekly{count = 1, target = [{3,3}], reward = [{100001,1},{100002,1},{100003,1},{90010017,14}]};
find(8) -> #cfg_weekly{count = 10, target = [{3,3}], reward = [{100001,1},{100002,1},{100003,1},{90010017,15}]};
find(_) -> undefined.

list() -> [6,7,8,1000,1001,2,5,1002,1,3,4].
