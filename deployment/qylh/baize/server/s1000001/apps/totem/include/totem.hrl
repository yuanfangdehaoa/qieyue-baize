%%%-------------------------------------------------------------------
%%% @author zjy
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 7月 2020 15:01
%%%-------------------------------------------------------------------
-author("zjy").
-ifndef(TOTEM_HRL).
-define(TOTEM_HRL, ok).

-record(cfg_totem,  {
  name  = "地狱犬",
  attr  = [{4,607},{2,16166},{6,303},{5,303}],
  skill = [{250101,1}],
  slot  = [{1,1},{2,1},{3,1},{4,1},{5,1}],
  color = 4
}).

-record(cfg_totem_equip,  {
  slot  = 1,
  star  = 0,
  base  = [{4,344},{2,16042}],
  rare1 = [{2001,41,1000},{7,118,1000},{8,118,1000},{9,118,1000},{10,118,1000},{11,118,1000},{12,118,1000}],
  rare2 = [],
  exp   = 48
}).

-record(cfg_totem_reinforce,  {
  exp   = 2567,
  total = 0,
  base  = [{4,0},{2,0}]
}).

-record(cfg_totem_summon, {
  restrict = [{level,380}],
  cost     = [{300006,2}]
}).

-record(r_totem, {id, equips=#{}, summon=false}).

-endif.
