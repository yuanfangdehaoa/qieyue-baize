#!/usr/bin/env bash

###=============================================================================
### @doc 签出指定分支
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
    fatal "usage: ${0} Branch Target WorkDir"
}

if [ $# -ne 3 ]; then
	usage
fi

Branch=${1}
Target=${2}
WorkDir=$(echo ${3} | sed 's/\/$//g')

check_branch ${Branch}

mkdir -p ${WorkDir}

if ! $(is_member ${Target} "server client both"); then
	fatal "Target有效值为: server | client | both"
fi

function checkout_server()
{
	if [ -d ${WorkDir}/server/.svn ]; then
		warn "服务端目录已存在，不再签出"
		return 0
	fi

	local SvnUrl=${SVN_OUTER_ROOT}/${Branch}/server
	check_svnurl ${SvnUrl}

	print "签出服务端: ${SvnUrl} => ${WorkDir}"
	cd ${WorkDir}
	svn co -q ${SvnUrl}
	maybe_fail "服务端签出失败"

	chmod a+x ${WorkDir}/server/xctl

	print "服务端签出成功"
}

function checkout_client()
{
	if [ -d ${WorkDir}/client/config/.svn ]; then
		warn "客户端目录已存在，不再签出"
		return 0
	fi

	if [ "${Branch}" == "develop" ]; then
		local SvnUrl=${SVN_INNER_ROOT}
	else
		local SvnUrl=${SVN_INNER_ROOT}/branch/${Branch}
	fi

	check_svnurl ${SvnUrl}

	print "签出客户端: ${SvnUrl} => ${WorkDir}"
	cd ${WorkDir}
	svn co -q ${SvnUrl}/client/project/game/Assets/LuaFramework/Lua/game/config/auto client/config
	maybe_fail "客户端签出失败"
	svn co -q ${SvnUrl}/client/project/game/Assets/LuaFramework/Lua/proto client/proto
	maybe_fail "客户端签出失败"
	svn co -q ${SvnUrl}/client/project/update/release/{android,ios} client/update
	maybe_fail "客户端签出失败"

	print "客户端签出成功"
}

function checkout_build()
{
	if [ -d ${WorkDir}/build/.svn ]; then
		warn "build目录已存在，不再签出"
		return 0
	fi

	local SvnUrl=${SVN_OUTER_ROOT}/${Branch}/build
	check_svnurl ${SvnUrl}

	print "签出build: ${SvnUrl} => ${WorkDir}"
	cd ${WorkDir}
	svn co -q ${SvnUrl}
	maybe_fail "build签出失败"

	print "build签出成功"
}

function checkout_config()
{
	if [ -d ${WorkDir}/config/.svn ]; then
		warn "配置目录已存在，不再签出"
		return 0
	fi

	local SvnUrl=${SVN_OUTER_ROOT}/${Branch}/config
	check_svnurl ${SvnUrl}

	print "签出配置: ${SvnUrl} => ${WorkDir}"
	cd ${WorkDir}
	svn co -q ${SvnUrl}
	maybe_fail "配置签出失败"

	print "配置签出成功"
}

function checkout_script()
{
	if [ -d ${WorkDir}/script/.svn ]; then
		warn "脚本目录已存在，不再签出"
		return 0
	fi

	local SvnUrl=${SVN_OUTER_ROOT}/${Branch}/script
	check_svnurl ${SvnUrl}

	print "签出脚本: ${SvnUrl} => ${WorkDir}"
	cd ${WorkDir}
	svn co -q ${SvnUrl}
	maybe_fail "脚本签出失败"

	print "脚本签出成功"
}

## 签出服务端相关目录
if [ "${Target}" == "server" -o "${Target}" == "both" ]; then
	checkout_server
	checkout_config
	checkout_script
	checkout_build
fi

## 签出客户端相关目录
if [ "${Target}" == "client" -o "${Target}" == "both" ]; then
	checkout_client
	checkout_config
	checkout_script
fi
