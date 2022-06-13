WorkDir = $(shell cd .. && pwd)

ServerDir = ${WorkDir}/server
ClientDir = ${WorkDir}/client
ConfigDir = ${WorkDir}/config
ScriptDir = ${WorkDir}/script

# 服务端编译目录
ServerBin = ${ServerDir}/ebin
# 客户端编译目录
# ClientBin =

SysConfig = ${ServerDir}/etc/sys.config

VPATH = ${ScriptDir}/src/ \
        $(wildcard ${ServerDir}/apps/*/src/) \
        $(wildcard ${ServerDir}/gen/*/src/)

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

all:server client

.PHONY:server
server:init_server deps cheat
	@ cd ${ServerDir} && make --no-print-directory erl lang=${LANG} plat=${PLAT}

ifndef notlocal
.PHONY:client
client:
else
.PHONY:client
client:init_client
	@ cd ${ConfigDir} && make --no-print-directory client lang=${LANG} plat=${PLAT}
endif

.PHONY:clean
clean:
	@ cd ${ConfigDir} && make --no-print-directory clean
	@ rm -rf ${ServerBin}/*

.PHONY:rebuild
rebuild:
	@ make clean
	@ make all

.PHONY:check
check:
	@ echo check config
	@ escript ${ServerDir}/priv/config-check ${Hrls}

.PHONE:extract
extract:
	@ go run ${ScriptDir}/src/extract_i18n.go ${ConfigDir}/excel

ifdef inc
.PHONY:hrl
hrl:
	@ find src gen -name "*.erl" | grep -rl "${inc}.hrl" | xargs touch -c
endif

.PHONY:print
print:
	@ echo ${ConfigDir}
	@ echo ${ScriptDir}

# ################################################################################
# ###                           初始化目录
# ################################################################################
.PHONY:init_server
init_server:
	@ if [ ! -f ${SysConfig} ]; then echo "缺少${SysConfig}配置\n" & exit 1; fi
	@ mkdir -p ${ServerBin}
	@ cd ${ConfigDir} && make --no-print-directory server

.PHONY:init_client
init_client:

################################################################################
###                          编译依赖文件
################################################################################
deps:${ServerBin}/update_behavior.beam


################################################################################
###                          编译 erl 文件
################################################################################
.PHONY:erl
erl:$(addprefix ${ServerBin}/,$(basename $(notdir $(wildcard ${ServerDir}/apps/*/src/*.app.src)))) \
	$(addprefix ${ServerBin}/,$(addsuffix .beam,$(basename $(notdir $(wildcard ${ServerDir}/apps/*/src/*.erl))))) \
	$(addprefix ${ServerBin}/,$(addsuffix .beam,$(basename $(notdir $(wildcard ${ServerDir}/gen/*/src/*.erl)))))

Include = $(addprefix -I ,$(wildcard ${ServerDir}/libs/*/include)) \
          $(addprefix -I ,$(wildcard ${ServerDir}/apps/*/include)) \
          $(addprefix -I ,$(wildcard ${ServerDir}/gen/*/include))
Erlc = erlc -Werror ${Include} -o ${ServerBin} -pa ${ServerDir}/deps -pa ${ServerDir}/ebin

ifndef nodebug
Erlc += "-DDEBUG"
endif

${ServerBin}/user_default.beam:user_default.erl
	@ echo compile `basename $<`
	@ ${Erlc} +debug_info $<
${ServerBin}/lager_transform.beam:lager_transform.erl
	@ echo compile `basename $<`
	@ ${Erlc} $<
${ServerBin}/%.beam:%.erl
	@ echo compile `basename $<`
	@ ${Erlc} +'{parse_transform,lager_transform}' $<

${ServerBin}/%.app:%.app.src
	@ /bin/cp -f $< $@

################################################################################
###                                 解析 GM 指令
################################################################################
.PHONY:cheat
cheat:${ConfigDir}/xml/cheat.xml

${ConfigDir}/xml/cheat.xml:game_cheat.erl parse_cheat.go
	@ echo parse game cheat
	@ go run ${ScriptDir}/src/parse_cheat.go $< $@
