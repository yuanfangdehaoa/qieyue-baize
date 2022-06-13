-ifndef(RANK_HRL).
-define(RANK_HRL, ok).

-record(cfg_rank, {
	  id    % 榜单id  RANK_ID_XXX
    , mode
	, type
	, size
    , page_size
	, limen
	, event
	, actid % 活动id
	, copy  % 开启榜单时复制
	, rank_limen
}).

-endif.
