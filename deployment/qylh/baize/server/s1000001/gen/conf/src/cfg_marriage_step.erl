% Automatically generated, do not edit
-module(cfg_marriage_step).

-compile([export_all]).
-compile(nowarn_export_all).

-include("marriage.hrl").

find(1) -> #cfg_marriage_step{target = {26,0,[],1}, reward = [{15129,1,1}]};
find(2) -> #cfg_marriage_step{target = {8,0,[],1}, reward = [{15130,1,1}]};
find(3) -> #cfg_marriage_step{target = {42,0,[],1}, reward = [{15131,1,1}]};
find(_) -> undefined.

list() -> [1,2,3].
