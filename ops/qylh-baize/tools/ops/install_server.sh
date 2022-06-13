#!/usr/bin/env bash

###=============================================================================
### @doc 装机
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Machines [-f]"
}

if [ $# -lt 1 ]; then
	usage
fi

Machines=${1}
Machines=$(make_hosts machine ${Machines})
confirm_ansible $@

playbook install_server.yml ${DIR_HOSTS}/machine.hosts \
	-e machines=${Machines}
