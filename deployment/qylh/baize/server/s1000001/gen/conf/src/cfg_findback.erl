% Automatically generated, do not edit
-module(cfg_findback).

-compile([export_all]).
-compile(nowarn_export_all).

-include("findback.hrl").

find("270@1") -> #cfg_findback{
	key             = "270@1",
	module          = daily_handler,
	cost            = [{90010005,2000},{90010004,250}],
	exp_type        = 1,
	params          = "3000",
	drops           = [{600001,2}],
	dropsgold       = [{600002,2}],
	event           = {7,3},
	role_count      = [],
	max_count       = 20,
	vip_role_count  = 0,
	vip_rights      = 0,
	vip_cost        = []
};
find("150@7") -> #cfg_findback{
	key             = "150@7",
	module          = dunge_exp,
	cost            = [{90010005,50000},{90010004,1750}],
	exp_type        = 1,
	params          = "24000",
	drops           = [],
	dropsgold       = [],
	event           = undefined,
	role_count      = [{2002,301}],
	max_count       = 2,
	vip_role_count  = {2003,301},
	vip_rights      = 4,
	vip_cost        = [{90010004,0}]
};
find("400@1") -> #cfg_findback{
	key             = "400@1",
	module          = escort_handler,
	cost            = [{90010005,8000},{90010004,250}],
	exp_type        = 1,
	params          = "4800",
	drops           = [{600001,2}],
	dropsgold       = [{600002,2}],
	event           = undefined,
	role_count      = [1005],
	max_count       = 3,
	vip_role_count  = 0,
	vip_rights      = 0,
	vip_cost        = []
};
find("150@10") -> #cfg_findback{
	key             = "150@10",
	module          = dunge_coin,
	cost            = [{90010005,60000},{90010004,1500}],
	exp_type        = 0,
	params          = "",
	drops           = [{1,[{600101,1}]},{2,[{600102,1}]},{3,[{600103,1},{31,1},{32,1},{33,1},{34,1}]},{4,[{600104,1},{31,1},{32,1},{33,1},{34,1}]},{5,[{600105,1},{31,1},{32,1},{33,1},{34,1}]},{6,[{600106,1},{31,1},{32,1},{33,1},{34,1}]},{7,[{600107,1},{31,1},{32,1},{33,1},{34,1}]}],
	dropsgold       = [{1,[{600301,1}]},{2,[{600302,1}]},{3,[{600303,1},{31,1},{32,1},{33,1},{34,1}]},{4,[{600304,1},{31,1},{32,1},{33,1},{34,1}]},{5,[{600305,1},{31,1},{32,1},{33,1},{34,1}]},{6,[{600306,1},{31,1},{32,1},{33,1},{34,1}]},{7,[{600307,1},{31,1},{32,1},{33,1},{34,1}]}],
	event           = {9,302},
	role_count      = [{2002,302},{2004,302}],
	max_count       = 2,
	vip_role_count  = {2003,302},
	vip_rights      = 9,
	vip_cost        = [{90010004,0}]
};
find("150@11") -> #cfg_findback{
	key             = "150@11",
	module          = dunge_equip,
	cost            = [{90010005,100000},{90010004,4000}],
	exp_type        = 0,
	params          = "",
	drops           = [{30201,[{140004,2},{140004,2},{140004,2},{140004,2},{140004,2},{140004,2},{140004,2},{140004,2},{141504,2},{5004,2},{5004,2},{7002,2}]},{30202,[{140005,2},{140005,2},{140005,2},{140005,2},{140005,2},{140005,2},{140005,2},{140005,2},{141505,2},{5005,2},{5005,2},{7003,2}]},{30203,[{140006,2},{140006,2},{140006,2},{140006,2},{140006,2},{140006,2},{140006,2},{140006,2},{141506,2},{5006,2},{5006,2},{7004,2}]},{30204,[{140007,2},{140007,2},{140007,2},{140007,2},{140007,2},{140007,2},{140007,2},{140007,2},{141507,2},{5007,2},{5007,2},{7005,2}]},{30205,[{140008,2},{140008,2},{140008,2},{140008,2},{140008,2},{140008,2},{140008,2},{140008,2},{141508,2},{142008,2},{143008,2},{5008,2},{5008,2},{7006,2}]},{30206,[{140009,2},{140009,2},{140009,2},{140009,2},{140009,2},{140009,2},{140009,2},{140009,2},{141509,2},{142009,2},{143009,2},{5009,2},{5009,2},{7007,2}]},{30207,[{140010,2},{140010,2},{140010,2},{140010,2},{140010,2},{140010,2},{140010,2},{140010,2},{141510,2},{142010,2},{143010,2},{5010,2},{5010,2},{7008,2}]},{30208,[{140011,2},{140011,2},{140011,2},{140011,2},{140011,2},{140011,2},{140011,2},{140011,2},{141511,2},{142011,2},{143011,2},{5011,2},{5011,2},{7009,2}]},{30209,[{140012,2},{140012,2},{140012,2},{140012,2},{140012,2},{140012,2},{140012,2},{140012,2},{141512,2},{142012,2},{143012,2},{5012,2},{5012,2},{7010,2}]},{30210,[{140013,2},{140013,2},{140013,2},{140013,2},{140013,2},{140013,2},{140013,2},{140013,2},{141513,2},{142013,2},{143013,2},{5013,2},{5013,2},{7011,2}]},{30211,[{140014,2},{140014,2},{140014,2},{140014,2},{140014,2},{140014,2},{140014,2},{140014,2},{141514,2},{142014,2},{143014,2},{5014,2},{5014,2},{7012,2}]},{30212,[{140015,2},{140015,2},{140015,2},{140015,2},{140015,2},{140015,2},{140015,2},{140015,2},{141515,2},{142015,2},{143015,2},{5015,2},{5015,2},{7013,2}]},{30213,[{140016,2},{140016,2},{140016,2},{140016,2},{140016,2},{140016,2},{140016,2},{140016,2},{141516,2},{142016,2},{143016,2},{5016,2},{5016,2},{7014,2}]}],
	dropsgold       = [{30201,[{140004,2},{140004,2},{140004,2},{140004,2},{140004,2},{140004,2},{140004,2},{140004,2},{141504,2},{5004,2},{5004,2},{7002,2}]},{30202,[{140005,2},{140005,2},{140005,2},{140005,2},{140005,2},{140005,2},{140005,2},{140005,2},{141505,2},{5005,2},{5005,2},{7003,2}]},{30203,[{140006,2},{140006,2},{140006,2},{140006,2},{140006,2},{140006,2},{140006,2},{140006,2},{141506,2},{5006,2},{5006,2},{7004,2}]},{30204,[{140007,2},{140007,2},{140007,2},{140007,2},{140007,2},{140007,2},{140007,2},{140007,2},{141507,2},{5007,2},{5007,2},{7005,2}]},{30205,[{140008,2},{140008,2},{140008,2},{140008,2},{140008,2},{140008,2},{140008,2},{140008,2},{141508,2},{142008,2},{143008,2},{5008,2},{5008,2},{7006,2}]},{30206,[{140009,2},{140009,2},{140009,2},{140009,2},{140009,2},{140009,2},{140009,2},{140009,2},{141509,2},{142009,2},{143009,2},{5009,2},{5009,2},{7007,2}]},{30207,[{140010,2},{140010,2},{140010,2},{140010,2},{140010,2},{140010,2},{140010,2},{140010,2},{141510,2},{142010,2},{143010,2},{5010,2},{5010,2},{7008,2}]},{30208,[{140011,2},{140011,2},{140011,2},{140011,2},{140011,2},{140011,2},{140011,2},{140011,2},{141511,2},{142011,2},{143011,2},{5011,2},{5011,2},{7009,2}]},{30209,[{140012,2},{140012,2},{140012,2},{140012,2},{140012,2},{140012,2},{140012,2},{140012,2},{141512,2},{142012,2},{143012,2},{5012,2},{5012,2},{7010,2}]},{30210,[{140013,2},{140013,2},{140013,2},{140013,2},{140013,2},{140013,2},{140013,2},{140013,2},{141513,2},{142013,2},{143013,2},{5013,2},{5013,2},{7011,2}]},{30211,[{140014,2},{140014,2},{140014,2},{140014,2},{140014,2},{140014,2},{140014,2},{140014,2},{141514,2},{142014,2},{143014,2},{5014,2},{5014,2},{7012,2}]},{30212,[{140015,2},{140015,2},{140015,2},{140015,2},{140015,2},{140015,2},{140015,2},{140015,2},{141515,2},{142015,2},{143015,2},{5015,2},{5015,2},{7013,2}]},{30213,[{140016,2},{140016,2},{140016,2},{140016,2},{140016,2},{140016,2},{140016,2},{140016,2},{141516,2},{142016,2},{143016,2},{5016,2},{5016,2},{7014,2}]}],
	event           = {21,304},
	role_count      = [{2002,304}],
	max_count       = 3,
	vip_role_count  = {2003,304},
	vip_rights      = 0,
	vip_cost        = []
};
find("150@8") -> #cfg_findback{
	key             = "150@8",
	module          = dunge_mount,
	cost            = [{90010005,60000},{90010004,2500}],
	exp_type        = 0,
	params          = "",
	drops           = [{30401,[{600401,2},{600402,2},{600403,2},{600404,2}]},{30402,[{600401,2},{600402,2},{600403,2},{600404,2}]},{30403,[{600401,2},{600402,2},{600403,2},{600404,2}]},{30404,[{600401,2},{600402,2},{600403,2},{600404,2}]}],
	dropsgold       = [{30401,[{600501,2},{600502,2},{600503,2},{600504,2}]},{30402,[{600501,2},{600502,2},{600503,2},{600504,2}]},{30403,[{600501,2},{600502,2},{600503,2},{600504,2}]},{30404,[{600501,2},{600502,2},{600503,2},{600504,2}]}],
	event           = {21,308},
	role_count      = [{2002,30401},{2002,30402},{2002,30403},{2002,30404},{2004,308},{2004,308},{2004,308},{2004,308}],
	max_count       = 4,
	vip_role_count  = 0,
	vip_rights      = 0,
	vip_cost        = []
};
find("150@9") -> #cfg_findback{
	key             = "150@9",
	module          = dunge_pet,
	cost            = [{90010005,50000},{90010004,4000}],
	exp_type        = 0,
	params          = "",
	drops           = [{80001,[{401401,8},{501401,1},{301010,1}]},{80002,[{402201,8},{502201,1},{302010,1}]},{80003,[{402901,8},{502901,1},{303010,1}]},{80004,[{403501,8},{503501,1},{304010,1}]},{80005,[{404101,8},{504101,1},{305010,1}]},{80006,[{404701,8},{504701,1},{306010,1}]},{80007,[{405201,8},{505201,1},{307010,1}]}],
	dropsgold       = [{80001,[{401401,4},{501401,1},{301010,1}]},{80002,[{402201,4},{502201,1},{302010,1}]},{80003,[{402901,4},{502901,1},{303010,1}]},{80004,[{403501,4},{503501,1},{304010,1}]},{80005,[{404101,4},{504101,1},{305010,1}]},{80006,[{404701,4},{504701,1},{306010,1}]},{80007,[{405201,4},{505201,1},{307010,1}]}],
	event           = {21,310},
	role_count      = [{2002,310}],
	max_count       = 2,
	vip_role_count  = {2003,310},
	vip_rights      = 0,
	vip_cost        = []
};
find("311@2") -> #cfg_findback{
	key             = "311@2",
	module          = arena_handler,
	cost            = [{90010005,8000},{90010004,250}],
	exp_type        = 1,
	params          = "2400",
	drops           = [{600201,2}],
	dropsgold       = [{600201,2}],
	event           = undefined,
	role_count      = [{2002,309}],
	max_count       = 10,
	vip_role_count  = {2003,309},
	vip_rights      = 30,
	vip_cost        = [{90010004,0}]
};
find(_) -> undefined.

keys() -> ["150@9","311@2","270@1","150@7","400@1","150@10","150@11","150@8"].
