% Automatically generated, do not edit
-module(cfg_stone).

-compile([export_all]).
-compile(nowarn_export_all).

-include("equip.hrl").

find(100032) -> #cfg_stone{
	id            = 100032,
	level         = 1,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{4,69},{6,16}],
	need_num      = 3,
	next_level_id = 100033,
	pre_level_id  = 0
};
find(100033) -> #cfg_stone{
	id            = 100033,
	level         = 2,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{4,139},{6,33}],
	need_num      = 3,
	next_level_id = 100034,
	pre_level_id  = 100032
};
find(100034) -> #cfg_stone{
	id            = 100034,
	level         = 3,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{4,256},{6,64}],
	need_num      = 3,
	next_level_id = 100035,
	pre_level_id  = 100033
};
find(100035) -> #cfg_stone{
	id            = 100035,
	level         = 4,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{4,458},{6,115}],
	need_num      = 3,
	next_level_id = 100036,
	pre_level_id  = 100034
};
find(100036) -> #cfg_stone{
	id            = 100036,
	level         = 5,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{4,801},{6,199}],
	need_num      = 3,
	next_level_id = 100037,
	pre_level_id  = 100035
};
find(100037) -> #cfg_stone{
	id            = 100037,
	level         = 6,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{4,1382},{6,345}],
	need_num      = 3,
	next_level_id = 100038,
	pre_level_id  = 100036
};
find(100038) -> #cfg_stone{
	id            = 100038,
	level         = 7,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{4,2371},{6,592}],
	need_num      = 3,
	next_level_id = 100039,
	pre_level_id  = 100037
};
find(100039) -> #cfg_stone{
	id            = 100039,
	level         = 8,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{4,4053},{6,1012}],
	need_num      = 3,
	next_level_id = 100040,
	pre_level_id  = 100038
};
find(100040) -> #cfg_stone{
	id            = 100040,
	level         = 9,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{4,6912},{6,1728}],
	need_num      = 3,
	next_level_id = 0,
	pre_level_id  = 100039
};
find(100041) -> #cfg_stone{
	id            = 100041,
	level         = 1,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{2,1389},{5,16}],
	need_num      = 3,
	next_level_id = 100042,
	pre_level_id  = 0
};
find(100042) -> #cfg_stone{
	id            = 100042,
	level         = 2,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{2,2784},{5,33}],
	need_num      = 3,
	next_level_id = 100043,
	pre_level_id  = 100041
};
find(100043) -> #cfg_stone{
	id            = 100043,
	level         = 3,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{2,5152},{5,64}],
	need_num      = 3,
	next_level_id = 100044,
	pre_level_id  = 100042
};
find(100044) -> #cfg_stone{
	id            = 100044,
	level         = 4,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{2,9177},{5,115}],
	need_num      = 3,
	next_level_id = 100045,
	pre_level_id  = 100043
};
find(100045) -> #cfg_stone{
	id            = 100045,
	level         = 5,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{2,16024},{5,199}],
	need_num      = 3,
	next_level_id = 100046,
	pre_level_id  = 100044
};
find(100046) -> #cfg_stone{
	id            = 100046,
	level         = 6,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{2,27660},{5,345}],
	need_num      = 3,
	next_level_id = 100047,
	pre_level_id  = 100045
};
find(100047) -> #cfg_stone{
	id            = 100047,
	level         = 7,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{2,47443},{5,592}],
	need_num      = 3,
	next_level_id = 100048,
	pre_level_id  = 100046
};
find(100048) -> #cfg_stone{
	id            = 100048,
	level         = 8,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{2,81069},{5,1012}],
	need_num      = 3,
	next_level_id = 100049,
	pre_level_id  = 100047
};
find(100049) -> #cfg_stone{
	id            = 100049,
	level         = 9,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{2,138240},{5,1728}],
	need_num      = 3,
	next_level_id = 0,
	pre_level_id  = 100048
};
find(_) -> undefined.
