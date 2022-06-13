#!/usr/bin/env bash

###=============================================================================
### @doc 编译项目
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
    fatal "usage: ${0} WorkDir"
}

if [ $# -ne 1 ]; then
	usage
fi

WorkDir=$(echo ${1} | sed 's/\/$//g')

if [ ! -d ${WorkDir} ]; then
	fatal "${WorkDir}目录不存在"
fi

if [ -d ${WorkDir}/server ]; then
	print "编译服务端"
	cd ${WorkDir}/server
	touch apps/util/src/ut_time.erl
	make ${WorkDir}/server/ebin/ut_time.beam notlocal=true lang=${CONVERT_TO} plat=${SUB_CONFIG}
	maybe_fail "服务端编译失败"
fi

print "编译完成"
