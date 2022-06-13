-ifndef(MARRIAGE_HRL).
-define(MARRIAGE_HRL, ok).

-record(cfg_marriage_step, {target, reward}).

% gold 暂存扣除的钻石，配置改了，也不会影响钻石返回数有误
-record(marriage_proposal, {proposer, type, is_aa, gold, ts}).

-record(cfg_marriage_type, {name, reward, title, cost, wcount}).

-record(cfg_marriage_ring, {grade, level, exp, ring}).

-endif.