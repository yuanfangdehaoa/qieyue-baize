-ifndef(EQUIP_HRL).
-define(EQUIP_HRL, ok).

%强化信息
-record(equip_strength, {
	  phase       %阶段
	, level       %等级
	, bless_value %祝福值
}).

%保存套装信息
-record(suite, {
	  active :: map()  %已激活的套装 套装id->激活数
	, maked  :: list() %已制作的部位列表 [slot, slot]
}).

%铸造
-record(equip_cast, {
	  cast        %等级
	, cost        %铸造消耗{BList, List}
}).



-record(cfg_equip, {
	  id
	, slot   	% 部位
	, order  	% 阶位
	, star   	% 星级
	, career 	% 职业限制
	, wake   	% 所需觉醒次数
	, base   	% 基础属性
	, rare1  	% 蓝色极品属性
	, rare2  	% 紫色极品属性
	, rare3  	% 橙色极品属性
	, rare4  	% 结婚极品属性
}).

%装备评分配置表
-record(cfg_equip_score, {
	   id        %属性对应的id
	 , ratio     %评分系数
}).


%装备强化上限表
-record(cfg_equip_strength_limit, {
	  id
	, slot      %部位
	, order     %阶位
	, color     %颜色
	, max_phase %强化最高段
}).

%装备强化配置表
-record(cfg_equip_strength, {
	  id
	, slot      %部位
	, phase     %段位
	, level     %等级
	, cost      %单次消耗
	, bless_value     %单次增加祝福值
	, max_bless_value %最大祝福值
	, prob            %强化成功概率
	, attrib          %增加的属性值
	, next_id         %下一级id
}).

%装备强化套装
-record(cfg_equip_strength_suite, {
	  id
	, phase     %段位
	, level     %等级
	, slots     %部位
	, num       %套装需要的数量
	, attrib    %增加的属性值
}).


%宝石
-record(cfg_stone, {
	  id            %item.id
	, level         %宝石等级
	, slots         %可以镶嵌的部位
	, attrib        %增加的属性值
	, need_num      %合成下一级需要的数量
	, next_level_id %下一级宝石id
	, pre_level_id  %上一级宝石id
}).

%宝石孔位解锁表
-record(cfg_stones_hole, {
	  id              %位置
	, open_condition  %解锁条件
}).

%晶石
-record(cfg_spar, {
	  id            %item.id
	, level         %晶石等级
	, slots         %可以镶嵌的部位
	, attrib        %增加的属性值
	, need_num      %合成下一级需要的数量
	, next_level_id %下一级晶石id
	, pre_level_id  %上一级晶石id
}).

%晶石孔位解锁表
-record(cfg_spar_unlock, {
	  id              %位置
	, open_condition  %解锁条件
}).


%套装
-record(cfg_equip_suite, {
	  id        
	, title           %套装名称
	, type_id         %套装类型
	, level           %套装等级（1-初级，2-进阶）
	, order           %需要装备阶位
	, slots           %组成部位
	, attribs         %套装属性{num,{{1,100},{2,100}} },...
}).


%套装制作
-record(cfg_equip_suite_make, {
	  id
	, slot            %部位
	, type_id         %类型
	, order           %阶位
	, level           %套装等级
	, cost            %消耗 {itemid,num},{itemid,num}
}).

%套装等级对应的颜色，星级
-record(cfg_equip_suite_level, {
	  level           %套装等级
	, name            %套装等级名字
	, color           %最低颜色要求
	, star            %最低星级要求
}).


%合成分类(一类)
-record(cfg_equip_combine_type, {
	  id             %一类id
	, title          %一类名称
	, sec_type       %二类 {id, title},...
}).

%合成分类(二类)
-record(cfg_equip_combine_sec_type, {
	  id             %二类id
	, open_level     %开放等级
	, thr_type       %三类 {id, title},...
}).

%合成分类(三类)
-record(cfg_equip_combine_thr_type, {
	  id              %三类id
	, four_type       %四类 {id, title},...
}).

%合成分类配置
-record(cfg_equip_combine_type_set, {
	  id             %cfg_equip_combine的二类，三类或四类id
	, combine_type   %合成方式
	, open_level     %开放等级
	, item_ids       %合成的物品 id,id
}).

%合成配置
-record(cfg_equip_combine, {
	  id             %item.id
	, gain           %获得物品
	, title          %名称
	, open_level     %开放等级
	, cost           %固定材料
	, other_cost     %不固定材料 xxxx,xxx,xxx,xxxx
	, min_num        %不固定材料最少需要数
	, max_num        %不固定材料最多需要数
	, probs          %概率 {数量，概率} {1,0},{2,0},{3,70},{4,85},{5,100}
	, compose_key
}).


%熔炼
-record(cfg_equip_smelt, {
	  id             
	, exp            %升到下一级的经验
	, attr           %属性加成
}).

%铸造
-record(cfg_equip_cast, {
	  slot           %部位
	, level          %等级
	, name           %名称
	, order          %需要的阶
	, color          %需要的颜色
	, star           %需要的星级
	, percent        %升品比例(万分比)
	, attr           %增加的属性
	, cost           %升到该级消耗
	, msgno          %传闻id
}).


%洗练
-record(cfg_equip_refine, {
	  slot            %部位
	, open            %开放等级
	, attr_libs       %道具id对应库id{道具id,库id}, ...
}).

%洗练属性库
-record(cfg_equip_refine_attr, {
	  id              %库id
	, attr_type       %属性种类{属性,权重}
	, attr            %属性{属性id,[{下限,上限,权重,颜色}, ...], ...}
}).

%评分库
-record(cfg_equip_refine_score, {
	  attr            %属性id
	, ratio           %系数
}).

%洗练杂表
-record(cfg_equip_refine_other, {
	  id
	, unlock          %解锁消耗{槽位, [itemid, num]}
	, lock            %锁定属性消耗 {锁定条数, [itemid, num]}
	, freecount       %免费洗练次数
	, cost            %洗练消耗
}).


-endif.