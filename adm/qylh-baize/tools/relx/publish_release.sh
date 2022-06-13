#!/usr/bin/env bash

###=============================================================================
### @doc 发布稳定服
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Version"
}

if [ $# -ne 1 ]; then
	usage
fi

Version=${1}

check_major_version ${Version}

WorkDir=${DIR_RELEASE}
RelxLog="[自动发布]发布${Version}版本"

## 发布客户端
if [ -d ${WorkDir}/client/config/.svn ]; then
	print "发布客户端"

	# SvnSrc=${SVN_INNER_DEVELOP}
	# SvnDst=${SVN_INNER_RELEASE}

	# svn rm -q -m "[自动发布]删除旧版本" ${SvnDst}/client/project/game >/dev/null 2>&1
	# svn mkdir --parents -q -m ${RelxLog} ${SvnDst}/client/project
	# svn cp -q -m ${RelxLog} ${SvnSrc}/client/project/game ${SvnDst}/client/project

	cd ${WorkDir}
	NewRev=$(lastest_revision ${WorkDir}/client/config)
	NewVsn=${Version}.${NewRev}
	echo ${NewVsn} > $(txt_version_client ${WorkDir})
	print "客户端版本更新为${NewVsn}"
fi

## 发布服务端
if [ -d ${WorkDir}/server/.svn ]; then
	print "发布服务端"

	# SvnSrc=${SVN_OUTER_DEVELOP}
	# SvnDst=${SVN_OUTER_RELEASE}

	# svn rm -q -m "[自动发布]删除旧版本" ${SvnDst} >/dev/null 2>&1
	# svn mkdir -q -m ${RelxLog} ${SvnDst}
	# svn cp -q -m ${RelxLog} ${SvnSrc}/{build,config,script,server} ${SvnDst}

	cd ${WorkDir}
	NewRev=$(lastest_revision ${WorkDir}/server)
	NewVsn=${Version}.${NewRev}
	echo ${NewVsn} > $(txt_version_server ${WorkDir})
	print "服务端版本更新为${NewVsn}"
fi
