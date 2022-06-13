%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(sdk).

-include("game.hrl").
-include("errno.hrl").

%% API
-export([verify/5]).
-export([payurl/1]).
-export([secret/0]).
-export([route/0, route/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 登录验证
-spec verify(string(), string(), string(), map(), inet:ip_address()) ->
	{ok, map()} | error.
%%-----------------------------------------------
verify(GameChan, Account, Token, SDKArgs, IP) ->
	case route() of
		{_, Mod} ->
			apply(Mod, verify, [GameChan, Account, Token, SDKArgs, IP]);
		_ ->
			ok
	end.

%%-----------------------------------------------
%% @doc 充值回调地址
-spec payurl(string()) ->
	string().
%%-----------------------------------------------
payurl(GameChan) ->
	Path   = "/api/server/payurl",
	Header = [{<<"Content-Type">>, <<"application/json">>}],
	Body   = jiffy:encode(#{
		<<"gamechan">> => ut_conv:to_binary(GameChan)
	}),
	?debug("payurl: ~p", [Body]),
	case web_request:get(Path, #{}, Header, Body) of
		{ok, Resp} ->
			Ret = jiffy:decode(Resp, [return_maps]),
			Url = ut_conv:to_list(maps:get(<<"payurl">>, Ret)),
			?_check(Url /= "", ?ERR_GAME_PAY_NOT_OPEN),
			Url;
		Error ->
			?debug("get payurl error: ~p", [Error]),
			throw(?err(?ERR_GAME_PAY_NOT_OPEN))
	end.


%%-----------------------------------------------
%% @doc app secret
-spec secret() ->
	string().
%%-----------------------------------------------
secret() ->
	"c0e302b5e145fdcc1f8382fef7230d69".

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
route() ->
	route(game_env:get_plat()).

%% 君海
route(junhai)   -> {junhai, sdk_junhai};   % 君海
route(shengshi) -> {junhai, sdk_shengshi}; % 圣识
route(changwan) -> {junhai, sdk_changwan}; % 畅玩
route(jjyou)    -> {junhai, sdk_jjyou};    % 99游
route(youjing)  -> {junhai, sdk_youjing};  % 游境
route(gemen)    -> {junhai, sdk_gemen};    % 哥们
route(jianguo)  -> {junhai, sdk_jianguo};  % 坚果
route(baoyu)    -> {junhai, sdk_baoyu};    % 暴雨
route(leju)     -> {junhai, sdk_leju};     % 乐聚
route(juliang)  -> {junhai, sdk_juliang};  % 聚量
route(jhhf)     -> {junhai, sdk_junhai};   % 君海混服
route(xingwan)  -> {junhai, sdk_junhai};   % 星湾
route(huawei)   -> {junhai, sdk_junhai};   % 华为
route(fenghong) -> {junhai, sdk_fenghong}; % 峰宏
route(xwen)     -> {junhai, sdk_xwen};     % 星湾
route(yixin)    -> {junhai, sdk_junhai};   % 壹心
route(lianyun)  -> {junhai, sdk_junhai};   % 联运
route(qiji)     -> {junhai, sdk_junhai};   % 联运2
route(chaomeng) -> {junhai, sdk_junhai};   % 超梦
route(jhbt) 		-> {junhai, sdk_junhai};	 % bt渠道
route(jhbt2) 		-> {junhai, sdk_junhai};	 % bt2渠道
route(jhjg) 		-> {junhai, sdk_junhai};   % 君海坚果
route(jhbt2hf) 		-> {junhai, sdk_junhai};   % 君海坚果
route(jhbt3) 		-> {junhai, sdk_junhai};   %% bt3渠道
%% 达达兔
route(dadatu)   -> {junhai, sdk_dadatu};   % 达达兔
%% 一格
route(yige)     -> {junhai, sdk_yige};     % 一格
%% 贪玩
route(tanwan)   -> {tanwan, sdk_twft}; % 繁体
route(twft)     -> {tanwan, sdk_twft}; % 繁体
route(twtw)     -> {tanwan, sdk_twtw}; % 泰文
route(twen)     -> {tanwan, sdk_twen}; % 英文
route(twkr)     -> {tanwan, sdk_twkr}; % 韩文
%% 白泽
route(baize)		-> {baize, sdk_baize};
route(Platform)        ->
	?error("could not find sdk : ~s~n", [Platform]),
	?nil.
