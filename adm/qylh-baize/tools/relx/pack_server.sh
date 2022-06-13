#!/usr/bin/env bash

###=============================================================================
### @doc 服务端版本包
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
    fatal "usage: $0 WorkDir PkgTag [-f]"
}

if [ $# -lt 2 ]; then
	usage
fi

WorkDir=${1}
PkgTag=${2}

check_dir ${WorkDir}

Version=$(current_version $(txt_version_server ${WorkDir}))
Package=$(pkg_server_release ${Version} ${PkgTag})

maybe_override_file ${Package} $@

# 打包时重新编译 ut_time ，避免将 debug 版本的模块更新出去
touch ${WorkDir}/server/apps/util/src/ut_time.erl

./build_project.sh ${WorkDir} false false
maybe_fail "编译失败"

print "开始打包${Package}"
rm -f ${Package}
mkdir -p $(dirname ${Package})
cd ${WorkDir}/server

tar -czf ${Package} --exclude=ebin/game_cheat.beam deps/ ebin/ priv/jiffy.so etc/version.txt xctl
maybe_fail "打包失败"

NewVsn=$(update_server_revision ${WorkDir})
print "服务端版本更新为${NewVsn}"
