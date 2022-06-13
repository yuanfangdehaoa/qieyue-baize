#!/usr/bin/env bash

###=============================================================================
### @doc 服务端更新包
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

Package=$(pkg_server_patch ${PkgTag})

maybe_override_file ${Package} $@

./build_project.sh ${WorkDir} false false
maybe_fail "编译失败"

cd ${WorkDir}/server
# 找出需要更新的文件
TxtUpdate=etc/update.txt
for File in $(cat ${TxtUpdate}); do
    if [ "${File}" == "xctl" ]; then
        FileList="${File} ${FileList}"
    else
        File=ebin/${File}.beam
        if [ -f ${File} ]; then
            FileList="${File} ${FileList}"
        else
            fatal "文件不存在:${File}"
        fi
    fi
done

if [ "${FileList}" == "" ]; then
    fatal "没有需要更新的文件"
fi

print "开始打包 ${Package}"
rm -f ${Package}
mkdir -p $(dirname ${Package})
tar -czf ${Package} ${FileList} ${TxtUpdate}
maybe_fail "打包失败"

print "更新列表"
for File in ${FileList}; do
    print "${File}"
done

NewVsn=$(update_server_revision ${WorkDir})
print "服务端版本更新为${NewVsn}"

cd ${DIR_TOOLS}/relx
./pack_server.sh ${WorkDir} ${PkgTag} -f
