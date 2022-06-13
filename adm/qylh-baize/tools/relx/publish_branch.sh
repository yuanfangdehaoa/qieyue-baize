#!/usr/bin/env bash

###=============================================================================
### @doc 发布分支
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0"
}

WorkDir=${DIR_RELEASE}

if [ -d ${WorkDir}/client/config/.svn ]; then
	SvnSrc=${SVN_INNER_RELEASE}
	SvnDst=${SVN_INNER_STABLES}
	Version=$(current_version $(txt_version_client ${WorkDir}))

	svn info ${SvnDst}/${Version} >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		fatal "${Version}分支已存在"
	fi

	print "发布客户端分支"

	Version=$(current_version $(txt_version_client ${WorkDir}))
	BackLog="[自动发布]发布${Version}分支"

	svn mkdir --parents -q -m ${BackLog} ${SvnDst}/${Version}/client/project/update/release/{android,ios}
	svn cp -q -m ${BackLog} ${SvnSrc}/client/project/game ${SvnDst}/${Version}/client/project/
fi

if [ -d ${WorkDir}/server/.svn ]; then
	SvnSrc=${SVN_OUTER_RELEASE}
	SvnDst=${SVN_OUTER_STABLES}
	Version=$(current_version $(txt_version_server ${WorkDir}))

	svn info ${SvnDst}/${Version} >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		fatal "${Version}分支已存在"
	fi

	print "发布服务端分支"

	Version=$(current_version $(txt_version_server ${WorkDir}))
	BackLog="[自动发布]发布${Version}分支"

	svn cp -q -m ${BackLog} ${SvnSrc}/build ${SvnDst}/build/${Version}
	svn cp -q -m ${BackLog} ${SvnSrc}/config ${SvnDst}/config/${Version}
	svn cp -q -m ${BackLog} ${SvnSrc}/script ${SvnDst}/script/${Version}
	svn cp -q -m ${BackLog} ${SvnSrc}/server ${SvnDst}/server/${Version}
fi
