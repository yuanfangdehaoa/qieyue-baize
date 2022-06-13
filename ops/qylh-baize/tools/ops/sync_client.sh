#!/usr/bin/env bash

###=============================================================================
### @doc 同步前端资源
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 WorkDir Platform OSType [-f]"
}

if [ $# -lt 3 ]; then
	usage
fi

WorkDir=${1}
Platform=${2}
OSType=${3}

check_dir ${WorkDir}
check_platform ${Platform}
check_ostype ${OSType}

confirm_ansible $@

svn up -q ${WorkDir}/client/update/${OSType}

print "正在对比MD5..."

python check_md5.py ${WorkDir}/client/update/${OSType}
if [ $? -ne 0 ]; then
	fatal "同步失败"
fi

playbook sync_directory.yml hosts/ops.hosts \
	-e machines=wan_cdn \
	-e src=${WorkDir}/client/update/${OSType}/ \
	-e dst=${DIR_CDN}/update/${Platform}/${OSType} \
	-e mode=push \
	-e own=www \
	-e grp=www
