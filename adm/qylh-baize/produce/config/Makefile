WorkDir = $(shell cd .. && pwd)

ServerDir = ${WorkDir}/server
ScriptDir = ${WorkDir}/script
ClientDir = ${WorkDir}/client
ConfigDir = ${WorkDir}/config
BuildDir  = ${WorkDir}/build
ProtoDir  = ${WorkDir}/config/proto

# 服务端生成目录
ServerGen = ${ServerDir}/gen
ServerConfigGen = ${ServerGen}/conf
ServerProtoGen  = ${ServerGen}/proto
ServerSceneGen  = ${ServerGen}/scene
ServerTableGen  = ${ServerGen}/table
# 客户端生成目录
ClientConfigGen = ${ClientDir}/config
ClientProtoGen  = ${ClientDir}/proto

SysConfig = ${ServerDir}/etc/sys.config

AdminDir = $(shell if [ -f ${SysConfig} ]; then grep -E "\bweb_dir\b" ${SysConfig} | awk -F", " '{print $$2}' | awk -F} '{print $$1}' | tr -d '"'; fi;)

VPATH = ${ProtoDir}/ \
        ${ScriptDir}/src/ \
        $(wildcard ${ConfigDir}/*) \
        $(wildcard ${ScriptDir}/src/tpl/*)

export GOPATH=${ScriptDir}

ifndef lang
	LANG = "never"
else
	LANG = ${lang}
endif

ifndef plat
	PLAT = "common"
else
	PLAT = ${plat}
endif

.PHONY:all
all:server client

.PHONY:server
server:i18n init_server
	@ make --no-print-directory xml2erl
	@ make --no-print-directory proto2erl
	@ make --no-print-directory excel2erl
	@ make --no-print-directory excel2php
	@ make --no-print-directory btree
	@ make --no-print-directory scene
	@ make --no-print-directory table

.PHONY:client
client:i18n init_client
	@ make --no-print-directory xml2lua
	@ make --no-print-directory proto2lua
	@ make --no-print-directory excel2lua
	@ make --no-print-directory excel2xml

.PHONY:proto
proto:proto2erl proto2lua

.PHONY:excel
excel:excel2erl excel2php excel2lua excel2xml

.PHONY:clean
clean:
	@ rm -rf ${ServerGen}/*

.PHONY:rebuild
rebuild:
	@ make clean
	@ make all

.PHONY:print
print:
	@ echo ${ServerConfigGen}

################################################################################
###                               初始化目录
################################################################################
.PHONY:init_server
init_server:
	@ mkdir -p ${ServerGen}/{conf,proto,scene,table}/{include,src}

.PHONY:init_client
init_client:
	@ mkdir -p ${ClientConfigGen}
	@ mkdir -p ${ClientProtoGen}

################################################################################
###                               解析 proto
################################################################################
ProtoFile = $(wildcard ${ProtoDir}/*.proto)

.PHONY:proto2erl
proto2erl: $(addprefix ${ServerProtoGen}/src/,$(addsuffix .erl,$(basename $(notdir ${ProtoFile})))) \
           ${ServerProtoGen}/include/proto.hrl

${ServerProtoGen}/src/%.erl:%.proto pb_comm.proto
	@ echo "parse `basename $<` for erl"
	@ escript ${ServerDir}/priv/protoc-erl -I ${ProtoDir} -o-erl ${ServerProtoGen}/src -o-hrl ${ServerProtoGen}/include -defaults-for-omitted-optionals -mapfields-as-maps $<

${ServerProtoGen}/include/proto.hrl:${ProtoFile} proto2erl.go
	@ go run ${ScriptDir}/src/proto2erl.go ${ProtoDir}/ ${ServerProtoGen}/



.PHONY:proto2lua
proto2lua: $(addprefix ${ClientProtoGen}/,$(addsuffix _pb.lua,$(basename $(notdir ${ProtoFile})))) \
           ${ClientProtoGen}/proto.lua

${ClientProtoGen}/%_pb.lua:%.proto pb_comm.proto
	@ echo "parse `basename $<` for lua"
	@ if hash protoc 2>/dev/null; then protoc -I ${ProtoDir} --lua_out=${ClientProtoGen} $<; fi

${ClientProtoGen}/proto.lua:${ProtoFile} proto2lua.go
	@ go run ${ScriptDir}/src/proto2lua.go ${ProtoDir}/ ${ClientProtoGen}/


################################################################################
###                                 解析 .xml
################################################################################
.PHONY:xml2erl
xml2erl:${ServerConfigGen}/include/errno.hrl \
	${ServerConfigGen}/include/enum.hrl \
	${ServerConfigGen}/include/log.hrl \
	${ServerConfigGen}/include/msgno.hrl

${ServerConfigGen}/include/%.hrl:%.xml %2erl.go ${ConfigDir}/excel/i18n.xlsx
	@ echo parse `basename $<`
	@ go run ${ScriptDir}/src/$*2erl.go $< ${ServerConfigGen}/ ${AdminDir}/

.PHONY:table
table:${ServerTableGen}/include/table.hrl

${ServerTableGen}/include/table.hrl:table.xml parse_table.go
	@ go run ${ScriptDir}/src/parse_table.go $< ${ServerTableGen}/

.PHONY:xml2lua
xml2lua:${ClientConfigGen}/errno.lua \
	${ClientConfigGen}/enum.lua \
	${ClientConfigGen}/logConsume.lua \
	${ClientConfigGen}/msgno.lua

${ClientConfigGen}/logConsume.lua:log.xml log2lua.go
	@ echo parse `basename $<`
	@ go run ${ScriptDir}/src/log2lua.go $< ${ClientConfigGen}/

${ClientConfigGen}/%.lua:%.xml %2lua.go ${ConfigDir}/excel/i18n.xlsx
	@ echo parse `basename $<`
	@ go run ${ScriptDir}/src/$*2lua.go $< ${ClientConfigGen}/ ${LANG}


################################################################################
#                                解析 excel
################################################################################
.PHONY:excel2erl
excel2erl:$(addsuffix .erl,$(addprefix ${ServerConfigGen}/src/cfg_, $(basename $(notdir $(wildcard ${ScriptDir}/src/tpl/excel/*.tpl)))))

${ServerConfigGen}/src/cfg_%.erl:%.xlsx %.tpl ${ConfigDir}/excel/i18n.xlsx ${ConfigDir}/excel/i18n_cols.xlsx
	@ echo parse `basename $<` for erl
	@ go run ${ScriptDir}/src/excel2erl.go $@ ${LANG} $^


.PHONY:excel2php
excel2php:$(addsuffix .php,$(addprefix ${AdminDir}/config/game_, $(subst php_,,$(basename $(notdir $(wildcard ${ScriptDir}/src/tpl/php/*.tpl))))))

${AdminDir}/config/game_%.php:%.xlsx php_%.tpl
	@ if [ -d ${AdminDir}/config ]; then echo parse `basename $<` for php && go run ${ScriptDir}/src/excel2php.go $^ $@; fi


ExcelFiles = $(basename $(filter-out ~%.xlsx,$(notdir $(wildcard ${ConfigDir}/excel/*.xlsx))))

.PHONY:excel2lua
excel2lua:$(foreach name,${ExcelFiles},$(shell if [ "`grep -w ${name} ${ConfigDir}/excel/ignore.txt`" == "" ]; then if [ "`grep -w ${name} ${ConfigDir}/excel/split.txt`" == "" ]; then echo ${ClientConfigGen}/db_${name}.lua; else echo ${ClientConfigGen}/${name}; fi; else echo ${ClientConfigGen}/ignore-${name}; fi))

${ClientConfigGen}/ignore-%:%.xlsx
	@ echo ignore $*

${ClientConfigGen}/%:%.xlsx ${ConfigDir}/excel/i18n.xlsx ${ConfigDir}/excel/i18n_cols.xlsx
	@ echo parse `basename $<` for lua
	@ mkdir -p ${ClientConfigGen}/$*
	@ touch ${ClientConfigGen}/$*
	@ go run ${ScriptDir}/src/excel2lua.go $< ${ClientConfigGen}/$*/db_$*.lua false true ${LANG}

${ClientConfigGen}/db_%.lua:%.xlsx ${ConfigDir}/excel/i18n.xlsx ${ConfigDir}/excel/i18n_cols.xlsx
	@ echo parse `basename $<` for lua
	@ go run ${ScriptDir}/src/excel2lua.go $< ${ClientConfigGen}/db_$*.lua false false ${LANG}


.PHONY:excel2xml
excel2xml:$(addsuffix .xml,$(addprefix ${ConfigDir}/xml/, $(subst xml_,,$(basename $(notdir $(wildcard ${ScriptDir}/src/tpl/xml/*.tpl))))))

${ConfigDir}/xml/%.xml:%.xlsx xml_%.tpl
	@ echo parse `basename $<` for xml
	@ go run ${ScriptDir}/src/excel2xml.go $^ $@ ${LANG}


################################################################################
###                                 解析行为树
################################################################################
CreepBTreeFiles = $(wildcard ${ConfigDir}/creep/*.mm)
DungeBTreeFiles = $(wildcard ${ConfigDir}/dunge/*.mm)

.PHONY:btree
btree:${ServerConfigGen}/src/cfg_creep_ai.erl \
      ${ServerConfigGen}/src/cfg_dunge_ai.erl

${ServerConfigGen}/src/cfg_creep_ai.erl:${CreepBTreeFiles} parse_btree.go
	@ echo parse creep btree
	@ go run ${ScriptDir}/src/parse_btree.go ${ConfigDir}/creep/ $@ ${ClientConfigGen}/

${ServerConfigGen}/src/cfg_dunge_ai.erl:${DungeBTreeFiles} parse_btree.go
	@ echo parse dunge btree
	@ go run ${ScriptDir}/src/parse_btree.go ${ConfigDir}/dunge/ $@ ${ClientConfigGen}/


################################################################################
#                                解析地图数据
################################################################################
.PHONY:scene
scene:$(addprefix ${ServerSceneGen}/src/scene_mask_,$(addsuffix .erl,$(basename $(notdir $(wildcard ${ConfigDir}/scene/*.bytes)))))
	@ /bin/cp -au ${BuildDir}/erl/scene/*.erl ${ServerSceneGen}/src/

${ServerSceneGen}/src/scene_mask_%.erl:%.bytes parse_scene.go
	@ echo parse `basename $<`
	@ go run ${ScriptDir}/src/parse_scene.go $< ${ServerSceneGen}

.PHONY:i18n
i18n:${ConfigDir}/excel/i18n.json

${ConfigDir}/excel/i18n.json: ${ConfigDir}/excel/i18n.xlsx ${ConfigDir}/excel/i18n_cols.xlsx
	@ echo parse i18n
	@ go run ${ScriptDir}/src/i18n2json.go ${ConfigDir}/excel