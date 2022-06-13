-ifndef(MALL_HRL).
-define(MALL_HRL, ok).

-define(MALL_REFRESH_DAY, 1).    %每日刷新
-define(MALL_REFRESH_WEEK, 2).   %每周刷新

-define(LIMIT_TYPE_TIME, 3).     %限时抢购（倒计时限购）


%购买记录
-record(mall_bought, {
	  last_refresh = 0 :: integer()   %上次刷新时间
	, bought_maps = #{} :: map()     %购买数量 id对应购买数
}).


-record(cfg_mall, {
	  id       
	, mall_type                %商品类型 {1,1}
    , name                     %名字
	, order                    %排序
    , item                     %物品 {item_id, num}
    , discount                 %折扣
    , price                    %售价 {gold, 100}
    , original_price           %原价 {gold, 100}
    , limit_type               %限购类型（0-不限购，1-每日限购，2-周限购，3-限时抢购）
    , limit_num                %限购数量
    , limit_vip                %购买限制vip
    , limit_pre_id             %限购前置id
    , limit_level              %限制等级
    , limit_open_days          %限制开服天数
    , limit_duration           %限制时间（秒）
    , limit_other              %其他限制
    , refresh                  %刷新间隔（0-不刷新，1-日刷新，2-周刷新）
    , activity                 %活动id
    , notify                   %是否系统公告
    , panel                    %打开界面
}).

-endif.