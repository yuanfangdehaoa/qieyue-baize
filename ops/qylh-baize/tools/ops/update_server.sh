#!/usr/bin/env bash

###=============================================================================
### @doc 热更指定服务端
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 PkgTag Platform Servers [-f]"
}

if [ $# -lt 3 ]; then
	usage
fi

PkgTag=${1}
Platform=${2}
Servers=${3}

check_platform ${Platform}

Package=$(pkg_server_patch ${PkgTag})

if [ ! -f ${Package} ]; then
	fatal "${Package}不存在"
fi

Servers=$(make_hosts ${Platform} ${Servers})

confirm_ansible $@

# 更新游戏服
playbook update_server.yml ${DIR_HOSTS}/${Platform}/server.hosts \
	-e servers=${Servers} \
	-e pkg=${Package}
