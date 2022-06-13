#!/usr/bin/env bash

###=============================================================================
### @doc 启动跨服
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

playbook start_server.yml ${DIR_HOSTS}/cross.hosts \
	-e servers=${Crosses}
