#!/usr/bin/env bash

###=============================================================================
### @doc 关闭跨服
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Platform Crosses [-f]"
}

if [ $# -lt 2 ]; then
	usage
fi

Platform=${1}
Crosses=${2}

check_platform ${Platform}

Crosses=$(make_hosts cross ${Crosses})

confirm_ansible $@

# 停止游戏服
playbook stop_server.yml ${DIR_HOSTS}/cross.hosts \
	-e servers=${Crosses} \
	-e backup_path=${DIR_BACKUP}
