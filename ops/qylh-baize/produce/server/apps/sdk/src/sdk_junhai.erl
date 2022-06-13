%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(sdk_junhai).

%% API
-export([verify/5]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
verify(GameChan, Account, Token, SDKArgs, IP) ->
	Path = case GameChan of
		"114678" -> % 汇智众通越狱1
			"/api/hzztyy1/verify";
		"114623" -> % 峰宏越狱1
			"/api/fenghongyy1/verify";
		"114626" -> % 峰宏正版1
			"/api/fenghongzb1/verify";
		"114783" -> % 氓兔越狱1
			"/api/mangtuyy1/verify";
		"114822" -> % 印象越狱1
			"/api/yinxiangyy1/verify";
		"114716" -> % 大臣越狱1
			"/api/dachenyy1/verify";
		"114825" -> % 小七越狱1
			"/api/xiaoqiyy1/verify";
		"114893" -> % TT语音越狱
			"/api/youjingios/verify";
		"114894" -> % 游戏fan越狱
			"/api/youjingios/verify";
		"114895" -> % 桃子游戏越狱
			"/api/youjingios/verify";
		"114896" -> % 曼巴越狱
			"/api/youjingios/verify";
		"114897" -> % 哥们越狱
			"/api/youjingios/verify";
		"114898" -> % 哪吒越狱
			"/api/youjingios/verify";
		"114899" -> % 重庆越狱
			"/api/youjingios/verify";
		"114900" -> % 魔豆越狱
			"/api/youjingios/verify";
		"114494" -> % 游境-聚量越狱
			"/api/youjingios/verify";
		"114959" -> % 简玩越狱1-BT版
			"/api/jianwanyy1/verify";
		"114826" -> % 超梦越狱1-BT版
			"/api/chaomengyy1/verify";
		"115073" -> % 坚果-277
			"/api/jianguo/verify";
		"115072" -> % 坚果-游戏fan
			"/api/jianguo/verify";
		"115071" -> % 坚果-九妖
			"/api/jianguo/verify";
		"218000" -> % 达达兔正版1
			"/api/ddt/verify";
	 	"9999" -> % 简玩越狱母包-BT2版
		 "/api/jianwanyy1/verify";
		"1200" -> % 简玩越狱2-BT2版
		 "/api/jianwanyy1/verify";
		"1300" -> % 简玩越狱2-BT3版
			"/api/jianwanyy2/verify";			 
		_ ->
			"/api/junhai/verify"
	end,
	sdk_common:verify(Path, GameChan, Account, Token, SDKArgs, IP).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
