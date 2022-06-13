-ifndef(PAY_HRL).
-define(PAY_HRL, ok).

-record(payment, {
	  app_order % 游戏订单号
	, sdk_order % 平台订单号
	, goods_id  % 商品id
	, total_fee % 充值金额
	, gain_gold % 获得元宝(不包括赠送的)
	, pay_time  % 充值时间
}).

-endif.