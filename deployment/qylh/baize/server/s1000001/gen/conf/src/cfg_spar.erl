% Automatically generated, do not edit
-module(cfg_spar).

-compile([export_all]).
-compile(nowarn_export_all).

-include("equip.hrl").

find(101001) -> #cfg_spar{
	id            = 101001,
	level         = 1,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{11,67},{7,67}],
	need_num      = 3,
	next_level_id = 101002,
	pre_level_id  = 0
};
find(101002) -> #cfg_spar{
	id            = 101002,
	level         = 2,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{11,135},{7,135}],
	need_num      = 3,
	next_level_id = 101003,
	pre_level_id  = 101001
};
find(101003) -> #cfg_spar{
	id            = 101003,
	level         = 3,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{11,252},{7,252}],
	need_num      = 3,
	next_level_id = 101004,
	pre_level_id  = 101002
};
find(101004) -> #cfg_spar{
	id            = 101004,
	level         = 4,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{11,300},{7,300},{9,300}],
	need_num      = 3,
	next_level_id = 101005,
	pre_level_id  = 101003
};
find(101005) -> #cfg_spar{
	id            = 101005,
	level         = 5,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{11,522},{7,522},{9,522}],
	need_num      = 3,
	next_level_id = 101006,
	pre_level_id  = 101004
};
find(101006) -> #cfg_spar{
	id            = 101006,
	level         = 6,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{11,900},{7,900},{9,900}],
	need_num      = 3,
	next_level_id = 101007,
	pre_level_id  = 101005
};
find(101007) -> #cfg_spar{
	id            = 101007,
	level         = 7,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{11,1545},{7,1545},{9,1545}],
	need_num      = 3,
	next_level_id = 101008,
	pre_level_id  = 101006
};
find(101008) -> #cfg_spar{
	id            = 101008,
	level         = 8,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{11,2640},{7,2640},{9,2640}],
	need_num      = 3,
	next_level_id = 101009,
	pre_level_id  = 101007
};
find(101009) -> #cfg_spar{
	id            = 101009,
	level         = 9,
	slots         = [1001,1002,1003,1004,1005],
	attrib        = [{11,4500},{7,4500},{9,4500}],
	need_num      = 3,
	next_level_id = 0,
	pre_level_id  = 101008
};
find(102001) -> #cfg_spar{
	id            = 102001,
	level         = 1,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{12,67},{8,67}],
	need_num      = 3,
	next_level_id = 102002,
	pre_level_id  = 0
};
find(102002) -> #cfg_spar{
	id            = 102002,
	level         = 2,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{12,135},{8,135}],
	need_num      = 3,
	next_level_id = 102003,
	pre_level_id  = 102001
};
find(102003) -> #cfg_spar{
	id            = 102003,
	level         = 3,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{12,252},{8,252}],
	need_num      = 3,
	next_level_id = 102004,
	pre_level_id  = 102002
};
find(102004) -> #cfg_spar{
	id            = 102004,
	level         = 4,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{12,300},{8,300},{10,300}],
	need_num      = 3,
	next_level_id = 102005,
	pre_level_id  = 102003
};
find(102005) -> #cfg_spar{
	id            = 102005,
	level         = 5,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{12,522},{8,522},{10,522}],
	need_num      = 3,
	next_level_id = 102006,
	pre_level_id  = 102004
};
find(102006) -> #cfg_spar{
	id            = 102006,
	level         = 6,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{12,900},{8,900},{10,900}],
	need_num      = 3,
	next_level_id = 102007,
	pre_level_id  = 102005
};
find(102007) -> #cfg_spar{
	id            = 102007,
	level         = 7,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{12,1545},{8,1545},{10,1545}],
	need_num      = 3,
	next_level_id = 102008,
	pre_level_id  = 102006
};
find(102008) -> #cfg_spar{
	id            = 102008,
	level         = 8,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{12,2640},{8,2640},{10,2640}],
	need_num      = 3,
	next_level_id = 102009,
	pre_level_id  = 102007
};
find(102009) -> #cfg_spar{
	id            = 102009,
	level         = 9,
	slots         = [1006,1007,1008,1009,1010],
	attrib        = [{12,4500},{8,4500},{10,4500}],
	need_num      = 3,
	next_level_id = 0,
	pre_level_id  = 102008
};
find(_) -> undefined.
