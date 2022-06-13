#!/usr/bin/env bash

###=============================================================================
### @doc 编译项目
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
    fatal "usage: ${0} WorkDir Rebuild IsDebug"
}

if [ $# -ne 3 ]; then
	usage
fi

WorkDir=$(echo ${1} | sed 's/\/$//g')
Rebuild=${2}
IsDebug=${3}

if [ ! -d ${WorkDir} ]; then
	fatal "${WorkDir}目录不存在"
fi

if ! $(is_bool ${Rebuild}); then
	fatal "Rebuild有效值为: true | false"
fi

if ! $(is_bool ${IsDebug}); then
	fatal "IsDebug有效值为: true | false"
fi

ExcelDir=${WorkDir}/config/excel
PlatDir=${WorkDir}/config/excel/${SUB_CONFIG}

function revert_config()
{
	Files=$(svn status ${WorkDir}/config/excel/*.xlsx | grep '^M' | tr -s ' ' | cut -d' ' -f2)
	if [ "${Files}" != "" ]; then
		svn revert -q ${Files}
	fi
}

if [ -d ${WorkDir}/server ]; then
	print "更新服务端"
	cd ${WorkDir}
	revert_config
#	svn up -q ${WorkDir}/{config,script,server,build}
	maybe_fail "服务端更新失败"

	check_config ${WorkDir}

	if [ -d ${PlatDir} ]; then
		print "拷贝 ${PlatDir} 目录下的配置到 ${ExcelDir} 中"
		/bin/cp -a ${PlatDir}/* ${ExcelDir}/ 2>/dev/null;
	fi

	print "编译服务端"
	if [ "${Rebuild}" == "true" ]; then
		cd ${WorkDir}/server && make clean
	fi

	cd ${WorkDir}/server
	if [ "${IsDebug}" == "false" ]; then
		make -j server notlocal=true nodebug=true lang=${CONVERT_TO} plat=${SUB_CONFIG}
	else
		make -j server notlocal=true lang=${CONVERT_TO} plat=${SUB_CONFIG}
	fi
	maybe_fail "服务端编译失败"
fi


if [ -d ${WorkDir}/client/config -a -d ${WorkDir}/client/proto ]; then
	print "更新客户端"
	cd ${WorkDir}
	revert_config
#	svn up -q ${WorkDir}/{config,script}
	maybe_fail "客户端更新失败"

	svn up -q ${WorkDir}/client/{config,proto}
	maybe_fail "客户端更新失败"

	if [ -d ${PlatDir} ]; then
		print "拷贝 ${PlatDir} 目录下的配置到 ${ExcelDir} 中"
		/bin/cp -a ${PlatDir}/* ${ExcelDir}/ 2>/dev/null;
	fi

	print "编译客户端"
	if [ "${Rebuild}" == "true" ]; then
		cd ${WorkDir}/config && make clean
	fi

	cd ${WorkDir}/config
	make -j client lang=${CONVERT_TO} plat=${SUB_CONFIG}
	maybe_fail "客户端编译失败"

	print "提交生成文件"
	cd ${WorkDir}/client/config
	svn up -q .
	svn add --no-ignore --force . 2>/dev/null
	svn ci -m "[自动发布]提交生成文件"
	maybe_fail "提交失败"

	cd ${WorkDir}/client/proto
	svn up -q .
	svn add --no-ignore --force . 2>/dev/null
	svn ci -m "[自动发布]提交生成文件" *.lua
	maybe_fail "提交失败"

	cd ${WorkDir}/config/xml
	FileList="creep.xml npc.xml"
	svn up -q .
	svn add --no-ignore ${FileList} 2>/dev/null
	svn ci -m "[自动发布]提交生成文件" ${FileList}
	maybe_fail "提交失败"
fi

print "编译完成"
