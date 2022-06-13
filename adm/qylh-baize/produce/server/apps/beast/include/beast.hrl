-ifndef(BEAST_HRL).
-define(BEAST_HRL, ok).

-record(cfg_beast_summon, {restrict, cost}).

-record(cfg_beast, {name, attr, skill, slot, color}).

-record(cfg_beast_equip, {slot,star,base,rare1,rare2,exp}).

-record(cfg_beast_reinforce, {exp,total,base}).

-record(r_beast, {id, equips=#{}, summon=false}).

-endif.