#!/usr/bin/env bash

###=============================================================================
### @doc 启动游戏服
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Platform Servers [-f]"
}

if [ $# -lt 2 ]; then
	usage
fi

Platform=${1}
Servers=${2}

check_platform ${Platform}

Servers=$(make_hosts ${Platform} ${Servers})

confirm_ansible $@

playbook start_server.yml ${DIR_HOSTS}/${Platform}/server.hosts \
	-e servers=${Servers}
