-ifndef(TITLE_HRL).
-define(TITLE_HRL, ok).


-record(cfg_title, {
	  id
	, type_id           %分类
	, name              %名字
	, res               %资源id
	, attrib            %增加属性
	, power             %战力
	, expire            %有效期（秒）
    , desc              %来源描述
}).

-endif.