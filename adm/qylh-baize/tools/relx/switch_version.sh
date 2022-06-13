#!/usr/bin/env bash

###=============================================================================
### @doc 切换版本
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
    fatal "usage: ${0} Version"
}

if [ $# -ne 1 ]; then
	usage
fi

Version=${1}

check_major_version ${Version}

WorkDir=${DIR_PRODUCE}

function switch_server()
{
	if [ -d ${WorkDir}/server/.svn ]; then
		local SvnUrl=${SVN_OUTER_STABLES}/server/${Version}
		check_svnurl ${SvnUrl}

		print "切换服务端"

		cd ${WorkDir}/server

		svn revert -q -R apps/
		svn revert -q -R deps/
		svn revert -q -R libs/
		svn revert -q -R priv/
		svn revert -q Makefile
		svn revert -q xctl

		svn switch -q --ignore-ancestry ${SvnUrl} .

		maybe_fail "服务端切换失败"

	    local NewRev=$(lastest_revision ${WorkDir}/server)
	    local TxtVsn=$(txt_version_server ${WorkDir})
	    echo ${Version}.${NewRev} > ${TxtVsn}

		chmod a+x ${WorkDir}/server/xctl
	fi
}

function switch_client()
{
	if [ -d ${WorkDir}/client/config/.svn ]; then
		local SvnUrl=${SVN_INNER_STABLES}/${Version}
		check_svnurl ${SvnUrl}

		print "切换客户端"

		cd ${WorkDir}/client/config
		svn revert -q -R .
		svn switch -q --ignore-ancestry ${SvnUrl}/client/project/game/Assets/LuaFramework/Lua/game/config/auto .
		maybe_fail "客户端切换失败"

		cd ${WorkDir}/client/proto
		svn revert -q -R .
		svn switch -q --ignore-ancestry ${SvnUrl}/client/project/game/Assets/LuaFramework/Lua/proto .
		maybe_fail "客户端切换失败"

		cd ${WorkDir}/client/update/android
		svn revert -q -R .
		svn switch -q --ignore-ancestry ${SvnUrl}/client/project/update/release/android .
		maybe_fail "客户端切换失败"

		local NewRev=$(lastest_revision ${WorkDir}/client/config)
	    local TxtVsn=$(txt_version_client ${WorkDir})
	    echo ${Version}.${NewRev} > ${TxtVsn}
	fi
}

function switch_build()
{
	if [ -d ${WorkDir}/build/.svn ]; then
		local SvnUrl=${SVN_OUTER_STABLES}/build/${Version}
		check_svnurl ${SvnUrl}

		print "切换build目录"
		cd ${WorkDir}/build
		svn revert -q -R .
		svn switch -q --ignore-ancestry ${SvnUrl} .
		maybe_fail "build目录切换失败"
	fi
}

function switch_config()
{
	if [ -d ${WorkDir}/config/.svn ]; then
		local SvnUrl=${SVN_OUTER_STABLES}/config/${Version}
		check_svnurl ${SvnUrl}

		print "切换config目录"
		cd ${WorkDir}/config
		svn revert -q -R .
		svn switch -q --ignore-ancestry ${SvnUrl} .
		maybe_fail "config目录切换失败"
	fi
}

function switch_script()
{
	if [ -d ${WorkDir}/script/.svn ]; then
		local SvnUrl=${SVN_OUTER_STABLES}/script/${Version}
		check_svnurl ${SvnUrl}

		print "切换script目录"
		cd ${WorkDir}/script
		svn revert -q -R .
		svn switch -q --ignore-ancestry ${SvnUrl} .
		maybe_fail "script目录切换失败"
	fi
}

switch_server
switch_client
switch_build
switch_config
switch_script

print "成功切换至${Version}版本"
