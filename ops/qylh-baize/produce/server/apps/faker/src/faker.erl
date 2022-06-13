%% @author rong
%% @doc 
-module(faker).

-include("game.hrl").

-export([is_fake/1, get/1, random/0, random/2]).

is_fake(RoleID) ->
    lists:member(RoleID, cfg_faker:list()).

get(ID) ->
    faker_manager:get(ID).

% 随机一个机器人，返回#faker
random() ->
    ID = ut_rand:choose(cfg_faker:list()),
    faker_manager:get(ID).

%随机抽取Num个机器人
random(Num, Repeat) ->
	IDs = ut_rand:choose(cfg_faker:list(), Num, Repeat),
	[faker_manager:get(ID) || ID <- IDs].
