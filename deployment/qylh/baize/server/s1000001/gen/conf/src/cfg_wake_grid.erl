% Automatically generated, do not edit
-module(cfg_wake_grid).

-compile([export_all]).
-compile(nowarn_export_all).

-include("wake.hrl").

find(1) -> #cfg_wake_grid{
	id       = 1,
	pre_id   = 0,
	next_id  = 2,
	cost     = [{12005,5}],
	cost_exp = [{90010002,1280584800000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(2) -> #cfg_wake_grid{
	id       = 2,
	pre_id   = 1,
	next_id  = 3,
	cost     = [{12005,6}],
	cost_exp = [{90010002,1920877200000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(3) -> #cfg_wake_grid{
	id       = 3,
	pre_id   = 2,
	next_id  = 4,
	cost     = [{12005,7}],
	cost_exp = [{90010002,2241026700000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(4) -> #cfg_wake_grid{
	id       = 4,
	pre_id   = 3,
	next_id  = 5,
	cost     = [{12005,8}],
	cost_exp = [{90010002,2561172900000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(5) -> #cfg_wake_grid{
	id       = 5,
	pre_id   = 4,
	next_id  = 6,
	cost     = [{12005,10}],
	cost_exp = [{90010002,3201465300000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(6) -> #cfg_wake_grid{
	id       = 6,
	pre_id   = 5,
	next_id  = 7,
	cost     = [{12005,11}],
	cost_exp = [{90010002,3498000000000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(7) -> #cfg_wake_grid{
	id       = 7,
	pre_id   = 6,
	next_id  = 8,
	cost     = [{12005,13}],
	cost_exp = [{90010002,4158000000000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(8) -> #cfg_wake_grid{
	id       = 8,
	pre_id   = 7,
	next_id  = 9,
	cost     = [{12005,14}],
	cost_exp = [{90010002,4455000000000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(9) -> #cfg_wake_grid{
	id       = 9,
	pre_id   = 8,
	next_id  = 10,
	cost     = [{12005,15}],
	cost_exp = [{90010002,4785000000000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(10) -> #cfg_wake_grid{
	id       = 10,
	pre_id   = 9,
	next_id  = 11,
	cost     = [{12005,16}],
	cost_exp = [{90010002,5115000000000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(11) -> #cfg_wake_grid{
	id       = 11,
	pre_id   = 10,
	next_id  = 12,
	cost     = [{12005,17}],
	cost_exp = [{90010002,5412000000000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(12) -> #cfg_wake_grid{
	id       = 12,
	pre_id   = 11,
	next_id  = 0,
	cost     = [{12005,18}],
	cost_exp = [{90010002,5742000000000}],
	attr     = [{4,1200},{2,16800},{5,360}]
};
find(13) -> #cfg_wake_grid{
	id       = 13,
	pre_id   = 0,
	next_id  = 14,
	cost     = [{12010,3}],
	cost_exp = [{90010002,242315861203807}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(14) -> #cfg_wake_grid{
	id       = 14,
	pre_id   = 13,
	next_id  = 15,
	cost     = [{12010,4}],
	cost_exp = [{90010002,283509557608454}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(15) -> #cfg_wake_grid{
	id       = 15,
	pre_id   = 14,
	next_id  = 16,
	cost     = [{12010,5}],
	cost_exp = [{90010002,324703254013102}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(16) -> #cfg_wake_grid{
	id       = 16,
	pre_id   = 15,
	next_id  = 17,
	cost     = [{12010,6}],
	cost_exp = [{90010002,365896950417749}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(17) -> #cfg_wake_grid{
	id       = 17,
	pre_id   = 16,
	next_id  = 18,
	cost     = [{12010,7}],
	cost_exp = [{90010002,407090646822396}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(18) -> #cfg_wake_grid{
	id       = 18,
	pre_id   = 17,
	next_id  = 19,
	cost     = [{12010,8}],
	cost_exp = [{90010002,448284343227044}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(19) -> #cfg_wake_grid{
	id       = 19,
	pre_id   = 18,
	next_id  = 20,
	cost     = [{12010,9}],
	cost_exp = [{90010002,489478039631691}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(20) -> #cfg_wake_grid{
	id       = 20,
	pre_id   = 19,
	next_id  = 21,
	cost     = [{12010,10}],
	cost_exp = [{90010002,530671736036338}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(21) -> #cfg_wake_grid{
	id       = 21,
	pre_id   = 20,
	next_id  = 22,
	cost     = [{12010,11}],
	cost_exp = [{90010002,571865432440985}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(22) -> #cfg_wake_grid{
	id       = 22,
	pre_id   = 21,
	next_id  = 23,
	cost     = [{12010,12}],
	cost_exp = [{90010002,613059128845632}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(23) -> #cfg_wake_grid{
	id       = 23,
	pre_id   = 22,
	next_id  = 24,
	cost     = [{12010,13}],
	cost_exp = [{90010002,654252825250280}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(24) -> #cfg_wake_grid{
	id       = 24,
	pre_id   = 23,
	next_id  = 25,
	cost     = [{12010,14}],
	cost_exp = [{90010002,695446521654927}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(25) -> #cfg_wake_grid{
	id       = 25,
	pre_id   = 24,
	next_id  = 26,
	cost     = [{12010,15}],
	cost_exp = [{90010002,736640218059574}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(26) -> #cfg_wake_grid{
	id       = 26,
	pre_id   = 25,
	next_id  = 27,
	cost     = [{12010,16}],
	cost_exp = [{90010002,777833914464221}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(27) -> #cfg_wake_grid{
	id       = 27,
	pre_id   = 26,
	next_id  = 0,
	cost     = [{12010,17}],
	cost_exp = [{90010002,819027610868869}],
	attr     = [{4,1380},{2,19320},{5,414}]
};
find(28) -> #cfg_wake_grid{
	id       = 28,
	pre_id   = 0,
	next_id  = 29,
	cost     = [{12011,5}],
	cost_exp = [{90010002,321178659668319}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(29) -> #cfg_wake_grid{
	id       = 29,
	pre_id   = 28,
	next_id  = 30,
	cost     = [{12011,6}],
	cost_exp = [{90010002,375779031811933}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(30) -> #cfg_wake_grid{
	id       = 30,
	pre_id   = 29,
	next_id  = 31,
	cost     = [{12011,7}],
	cost_exp = [{90010002,430379403955548}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(31) -> #cfg_wake_grid{
	id       = 31,
	pre_id   = 30,
	next_id  = 32,
	cost     = [{12011,8}],
	cost_exp = [{90010002,484979776099162}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(32) -> #cfg_wake_grid{
	id       = 32,
	pre_id   = 31,
	next_id  = 33,
	cost     = [{12011,9}],
	cost_exp = [{90010002,539580148242776}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(33) -> #cfg_wake_grid{
	id       = 33,
	pre_id   = 32,
	next_id  = 34,
	cost     = [{12011,10}],
	cost_exp = [{90010002,594180520386390}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(34) -> #cfg_wake_grid{
	id       = 34,
	pre_id   = 33,
	next_id  = 35,
	cost     = [{12011,11}],
	cost_exp = [{90010002,648780892530005}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(35) -> #cfg_wake_grid{
	id       = 35,
	pre_id   = 34,
	next_id  = 36,
	cost     = [{12011,12}],
	cost_exp = [{90010002,703381264673619}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(36) -> #cfg_wake_grid{
	id       = 36,
	pre_id   = 35,
	next_id  = 37,
	cost     = [{12011,13}],
	cost_exp = [{90010002,757981636817233}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(37) -> #cfg_wake_grid{
	id       = 37,
	pre_id   = 36,
	next_id  = 38,
	cost     = [{12011,14}],
	cost_exp = [{90010002,812582008960847}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(38) -> #cfg_wake_grid{
	id       = 38,
	pre_id   = 37,
	next_id  = 39,
	cost     = [{12011,15}],
	cost_exp = [{90010002,823823262049239}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(39) -> #cfg_wake_grid{
	id       = 39,
	pre_id   = 38,
	next_id  = 40,
	cost     = [{12011,16}],
	cost_exp = [{90010002,875693615585672}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(40) -> #cfg_wake_grid{
	id       = 40,
	pre_id   = 39,
	next_id  = 41,
	cost     = [{12011,17}],
	cost_exp = [{90010002,927563969122106}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(41) -> #cfg_wake_grid{
	id       = 41,
	pre_id   = 40,
	next_id  = 42,
	cost     = [{12011,18}],
	cost_exp = [{90010002,979434322658539}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(42) -> #cfg_wake_grid{
	id       = 42,
	pre_id   = 41,
	next_id  = 43,
	cost     = [{12011,19}],
	cost_exp = [{90010002,1031304676194970}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(43) -> #cfg_wake_grid{
	id       = 43,
	pre_id   = 42,
	next_id  = 44,
	cost     = [{12011,20}],
	cost_exp = [{90010002,1083175029731400}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(44) -> #cfg_wake_grid{
	id       = 44,
	pre_id   = 43,
	next_id  = 45,
	cost     = [{12011,21}],
	cost_exp = [{90010002,1135045383267840}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(45) -> #cfg_wake_grid{
	id       = 45,
	pre_id   = 44,
	next_id  = 46,
	cost     = [{12011,22}],
	cost_exp = [{90010002,1186915736804270}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(46) -> #cfg_wake_grid{
	id       = 46,
	pre_id   = 45,
	next_id  = 47,
	cost     = [{12011,23}],
	cost_exp = [{90010002,1238786090340710}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(47) -> #cfg_wake_grid{
	id       = 47,
	pre_id   = 46,
	next_id  = 0,
	cost     = [{12011,24}],
	cost_exp = [{90010002,1302626525462470}],
	attr     = [{4,1500},{2,21000},{5,450}]
};
find(48) -> #cfg_wake_grid{
	id       = 48,
	pre_id   = 0,
	next_id  = 49,
	cost     = [{12012,5}],
	cost_exp = [{90010002,646175629876819}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(49) -> #cfg_wake_grid{
	id       = 49,
	pre_id   = 48,
	next_id  = 50,
	cost     = [{12012,6}],
	cost_exp = [{90010002,756025486955879}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(50) -> #cfg_wake_grid{
	id       = 50,
	pre_id   = 49,
	next_id  = 51,
	cost     = [{12012,7}],
	cost_exp = [{90010002,865875344034938}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(51) -> #cfg_wake_grid{
	id       = 51,
	pre_id   = 50,
	next_id  = 52,
	cost     = [{12012,8}],
	cost_exp = [{90010002,975725201113997}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(52) -> #cfg_wake_grid{
	id       = 52,
	pre_id   = 51,
	next_id  = 53,
	cost     = [{12012,9}],
	cost_exp = [{90010002,1085575058193060}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(53) -> #cfg_wake_grid{
	id       = 53,
	pre_id   = 52,
	next_id  = 54,
	cost     = [{12012,10}],
	cost_exp = [{90010002,1195424915272120}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(54) -> #cfg_wake_grid{
	id       = 54,
	pre_id   = 53,
	next_id  = 55,
	cost     = [{12012,11}],
	cost_exp = [{90010002,1305274772351170}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(55) -> #cfg_wake_grid{
	id       = 55,
	pre_id   = 54,
	next_id  = 56,
	cost     = [{12012,12}],
	cost_exp = [{90010002,1415124629430230}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(56) -> #cfg_wake_grid{
	id       = 56,
	pre_id   = 55,
	next_id  = 57,
	cost     = [{12012,13}],
	cost_exp = [{90010002,1524974486509290}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(57) -> #cfg_wake_grid{
	id       = 57,
	pre_id   = 56,
	next_id  = 58,
	cost     = [{12012,14}],
	cost_exp = [{90010002,1634824343588350}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(58) -> #cfg_wake_grid{
	id       = 58,
	pre_id   = 57,
	next_id  = 59,
	cost     = [{12012,15}],
	cost_exp = [{90010002,1744674200667410}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(59) -> #cfg_wake_grid{
	id       = 59,
	pre_id   = 58,
	next_id  = 60,
	cost     = [{12012,16}],
	cost_exp = [{90010002,1854524057746470}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(60) -> #cfg_wake_grid{
	id       = 60,
	pre_id   = 59,
	next_id  = 61,
	cost     = [{12012,17}],
	cost_exp = [{90010002,1964373914825530}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(61) -> #cfg_wake_grid{
	id       = 61,
	pre_id   = 60,
	next_id  = 62,
	cost     = [{12012,18}],
	cost_exp = [{90010002,2074223771904590}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(62) -> #cfg_wake_grid{
	id       = 62,
	pre_id   = 61,
	next_id  = 63,
	cost     = [{12012,19}],
	cost_exp = [{90010002,2101200474774270}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(63) -> #cfg_wake_grid{
	id       = 63,
	pre_id   = 62,
	next_id  = 64,
	cost     = [{12012,20}],
	cost_exp = [{90010002,2123794028266470}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(64) -> #cfg_wake_grid{
	id       = 64,
	pre_id   = 63,
	next_id  = 65,
	cost     = [{12012,21}],
	cost_exp = [{90010002,2146387581758660}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(65) -> #cfg_wake_grid{
	id       = 65,
	pre_id   = 64,
	next_id  = 66,
	cost     = [{12012,22}],
	cost_exp = [{90010002,2168981135250860}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(66) -> #cfg_wake_grid{
	id       = 66,
	pre_id   = 65,
	next_id  = 67,
	cost     = [{12012,23}],
	cost_exp = [{90010002,2191574688743060}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(67) -> #cfg_wake_grid{
	id       = 67,
	pre_id   = 66,
	next_id  = 68,
	cost     = [{12012,24}],
	cost_exp = [{90010002,2214168242235250}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(68) -> #cfg_wake_grid{
	id       = 68,
	pre_id   = 67,
	next_id  = 69,
	cost     = [{12012,25}],
	cost_exp = [{90010002,2236761795727450}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(69) -> #cfg_wake_grid{
	id       = 69,
	pre_id   = 68,
	next_id  = 70,
	cost     = [{12012,26}],
	cost_exp = [{90010002,2259355349219640}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(70) -> #cfg_wake_grid{
	id       = 70,
	pre_id   = 69,
	next_id  = 71,
	cost     = [{12012,27}],
	cost_exp = [{90010002,2281948902711840}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(71) -> #cfg_wake_grid{
	id       = 71,
	pre_id   = 70,
	next_id  = 72,
	cost     = [{12012,28}],
	cost_exp = [{90010002,2304542456204040}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(72) -> #cfg_wake_grid{
	id       = 72,
	pre_id   = 71,
	next_id  = 0,
	cost     = [{12012,29}],
	cost_exp = [{90010002,2327136009696240}],
	attr     = [{4,1575},{2,22050},{5,472}]
};
find(73) -> #cfg_wake_grid{
	id       = 73,
	pre_id   = 0,
	next_id  = 74,
	cost     = [{12013,5}],
	cost_exp = [{90010002,910006202393571}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(74) -> #cfg_wake_grid{
	id       = 74,
	pre_id   = 73,
	next_id  = 75,
	cost     = [{12013,6}],
	cost_exp = [{90010002,1064707256800480}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(75) -> #cfg_wake_grid{
	id       = 75,
	pre_id   = 74,
	next_id  = 76,
	cost     = [{12013,7}],
	cost_exp = [{90010002,1219408311207380}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(76) -> #cfg_wake_grid{
	id       = 76,
	pre_id   = 75,
	next_id  = 77,
	cost     = [{12013,8}],
	cost_exp = [{90010002,1374109365614290}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(77) -> #cfg_wake_grid{
	id       = 77,
	pre_id   = 76,
	next_id  = 78,
	cost     = [{12013,9}],
	cost_exp = [{90010002,1528810420021200}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(78) -> #cfg_wake_grid{
	id       = 78,
	pre_id   = 77,
	next_id  = 79,
	cost     = [{12013,10}],
	cost_exp = [{90010002,1683511474428110}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(79) -> #cfg_wake_grid{
	id       = 79,
	pre_id   = 78,
	next_id  = 80,
	cost     = [{12013,11}],
	cost_exp = [{90010002,1838212528835010}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(80) -> #cfg_wake_grid{
	id       = 80,
	pre_id   = 79,
	next_id  = 81,
	cost     = [{12013,12}],
	cost_exp = [{90010002,1992913583241920}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(81) -> #cfg_wake_grid{
	id       = 81,
	pre_id   = 80,
	next_id  = 82,
	cost     = [{12013,13}],
	cost_exp = [{90010002,2147614637648830}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(82) -> #cfg_wake_grid{
	id       = 82,
	pre_id   = 81,
	next_id  = 83,
	cost     = [{12013,14}],
	cost_exp = [{90010002,2302315692055730}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(83) -> #cfg_wake_grid{
	id       = 83,
	pre_id   = 82,
	next_id  = 84,
	cost     = [{12013,15}],
	cost_exp = [{90010002,2334165909139510}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(84) -> #cfg_wake_grid{
	id       = 84,
	pre_id   = 83,
	next_id  = 85,
	cost     = [{12013,16}],
	cost_exp = [{90010002,2481131910826070}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(85) -> #cfg_wake_grid{
	id       = 85,
	pre_id   = 84,
	next_id  = 86,
	cost     = [{12013,17}],
	cost_exp = [{90010002,2628097912512630}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(86) -> #cfg_wake_grid{
	id       = 86,
	pre_id   = 85,
	next_id  = 87,
	cost     = [{12013,18}],
	cost_exp = [{90010002,2775063914199190}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(87) -> #cfg_wake_grid{
	id       = 87,
	pre_id   = 86,
	next_id  = 88,
	cost     = [{12013,19}],
	cost_exp = [{90010002,2922029915885750}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(88) -> #cfg_wake_grid{
	id       = 88,
	pre_id   = 87,
	next_id  = 89,
	cost     = [{12013,20}],
	cost_exp = [{90010002,3068995917572320}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(89) -> #cfg_wake_grid{
	id       = 89,
	pre_id   = 88,
	next_id  = 90,
	cost     = [{12013,21}],
	cost_exp = [{90010002,3215961919258880}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(90) -> #cfg_wake_grid{
	id       = 90,
	pre_id   = 89,
	next_id  = 91,
	cost     = [{12013,22}],
	cost_exp = [{90010002,3362927920945440}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(91) -> #cfg_wake_grid{
	id       = 91,
	pre_id   = 90,
	next_id  = 92,
	cost     = [{12013,23}],
	cost_exp = [{90010002,3509893922632000}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(92) -> #cfg_wake_grid{
	id       = 92,
	pre_id   = 91,
	next_id  = 93,
	cost     = [{12013,24}],
	cost_exp = [{90010002,3690775155477000}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(93) -> #cfg_wake_grid{
	id       = 93,
	pre_id   = 92,
	next_id  = 94,
	cost     = [{12013,25}],
	cost_exp = [{90010002,3871656388322000}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(94) -> #cfg_wake_grid{
	id       = 94,
	pre_id   = 93,
	next_id  = 95,
	cost     = [{12013,26}],
	cost_exp = [{90010002,4052537621167000}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(95) -> #cfg_wake_grid{
	id       = 95,
	pre_id   = 94,
	next_id  = 96,
	cost     = [{12013,27}],
	cost_exp = [{90010002,4233418854012000}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(96) -> #cfg_wake_grid{
	id       = 96,
	pre_id   = 95,
	next_id  = 97,
	cost     = [{12013,28}],
	cost_exp = [{90010002,4414300086857000}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(97) -> #cfg_wake_grid{
	id       = 97,
	pre_id   = 96,
	next_id  = 98,
	cost     = [{12013,29}],
	cost_exp = [{90010002,4595181319702000}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(98) -> #cfg_wake_grid{
	id       = 98,
	pre_id   = 97,
	next_id  = 99,
	cost     = [{12013,30}],
	cost_exp = [{90010002,4776062552546990}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(99) -> #cfg_wake_grid{
	id       = 99,
	pre_id   = 98,
	next_id  = 100,
	cost     = [{12013,31}],
	cost_exp = [{90010002,4956943785391990}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(100) -> #cfg_wake_grid{
	id       = 100,
	pre_id   = 99,
	next_id  = 101,
	cost     = [{12013,32}],
	cost_exp = [{90010002,5137825018236990}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(101) -> #cfg_wake_grid{
	id       = 101,
	pre_id   = 100,
	next_id  = 102,
	cost     = [{12013,33}],
	cost_exp = [{90010002,5318706251081990}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(102) -> #cfg_wake_grid{
	id       = 102,
	pre_id   = 101,
	next_id  = 0,
	cost     = [{12013,34}],
	cost_exp = [{90010002,5499587483926990}],
	attr     = [{4,1732},{2,24255},{5,519}]
};
find(103) -> #cfg_wake_grid{
	id       = 103,
	pre_id   = 0,
	next_id  = 104,
	cost     = [{12014,10}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(104) -> #cfg_wake_grid{
	id       = 104,
	pre_id   = 103,
	next_id  = 105,
	cost     = [{12014,10}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(105) -> #cfg_wake_grid{
	id       = 105,
	pre_id   = 104,
	next_id  = 106,
	cost     = [{12014,10}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(106) -> #cfg_wake_grid{
	id       = 106,
	pre_id   = 105,
	next_id  = 107,
	cost     = [{12014,10}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(107) -> #cfg_wake_grid{
	id       = 107,
	pre_id   = 106,
	next_id  = 108,
	cost     = [{12014,10}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(108) -> #cfg_wake_grid{
	id       = 108,
	pre_id   = 107,
	next_id  = 109,
	cost     = [{12014,10}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(109) -> #cfg_wake_grid{
	id       = 109,
	pre_id   = 108,
	next_id  = 110,
	cost     = [{12014,10}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(110) -> #cfg_wake_grid{
	id       = 110,
	pre_id   = 109,
	next_id  = 111,
	cost     = [{12014,10}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(111) -> #cfg_wake_grid{
	id       = 111,
	pre_id   = 110,
	next_id  = 112,
	cost     = [{12014,10}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(112) -> #cfg_wake_grid{
	id       = 112,
	pre_id   = 111,
	next_id  = 113,
	cost     = [{12014,10}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(113) -> #cfg_wake_grid{
	id       = 113,
	pre_id   = 112,
	next_id  = 114,
	cost     = [{12014,15}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(114) -> #cfg_wake_grid{
	id       = 114,
	pre_id   = 113,
	next_id  = 115,
	cost     = [{12014,15}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(115) -> #cfg_wake_grid{
	id       = 115,
	pre_id   = 114,
	next_id  = 116,
	cost     = [{12014,15}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(116) -> #cfg_wake_grid{
	id       = 116,
	pre_id   = 115,
	next_id  = 117,
	cost     = [{12014,15}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(117) -> #cfg_wake_grid{
	id       = 117,
	pre_id   = 116,
	next_id  = 118,
	cost     = [{12014,15}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(118) -> #cfg_wake_grid{
	id       = 118,
	pre_id   = 117,
	next_id  = 119,
	cost     = [{12014,15}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(119) -> #cfg_wake_grid{
	id       = 119,
	pre_id   = 118,
	next_id  = 120,
	cost     = [{12014,15}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(120) -> #cfg_wake_grid{
	id       = 120,
	pre_id   = 119,
	next_id  = 121,
	cost     = [{12014,15}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(121) -> #cfg_wake_grid{
	id       = 121,
	pre_id   = 120,
	next_id  = 122,
	cost     = [{12014,15}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(122) -> #cfg_wake_grid{
	id       = 122,
	pre_id   = 121,
	next_id  = 123,
	cost     = [{12014,15}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(123) -> #cfg_wake_grid{
	id       = 123,
	pre_id   = 122,
	next_id  = 124,
	cost     = [{12014,20}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(124) -> #cfg_wake_grid{
	id       = 124,
	pre_id   = 123,
	next_id  = 125,
	cost     = [{12014,20}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(125) -> #cfg_wake_grid{
	id       = 125,
	pre_id   = 124,
	next_id  = 126,
	cost     = [{12014,20}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(126) -> #cfg_wake_grid{
	id       = 126,
	pre_id   = 125,
	next_id  = 127,
	cost     = [{12014,20}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(127) -> #cfg_wake_grid{
	id       = 127,
	pre_id   = 126,
	next_id  = 128,
	cost     = [{12014,20}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(128) -> #cfg_wake_grid{
	id       = 128,
	pre_id   = 127,
	next_id  = 129,
	cost     = [{12014,20}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(129) -> #cfg_wake_grid{
	id       = 129,
	pre_id   = 128,
	next_id  = 130,
	cost     = [{12014,20}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(130) -> #cfg_wake_grid{
	id       = 130,
	pre_id   = 129,
	next_id  = 131,
	cost     = [{12014,20}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(131) -> #cfg_wake_grid{
	id       = 131,
	pre_id   = 130,
	next_id  = 132,
	cost     = [{12014,20}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(132) -> #cfg_wake_grid{
	id       = 132,
	pre_id   = 131,
	next_id  = 133,
	cost     = [{12014,20}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(133) -> #cfg_wake_grid{
	id       = 133,
	pre_id   = 132,
	next_id  = 134,
	cost     = [{12014,30}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(134) -> #cfg_wake_grid{
	id       = 134,
	pre_id   = 133,
	next_id  = 135,
	cost     = [{12014,30}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(135) -> #cfg_wake_grid{
	id       = 135,
	pre_id   = 134,
	next_id  = 136,
	cost     = [{12014,30}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(136) -> #cfg_wake_grid{
	id       = 136,
	pre_id   = 135,
	next_id  = 137,
	cost     = [{12014,30}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(137) -> #cfg_wake_grid{
	id       = 137,
	pre_id   = 136,
	next_id  = 0,
	cost     = [{12014,30}],
	cost_exp = [],
	attr     = [{4,1991},{2,27893},{5,596}]
};
find(_) -> undefined.
