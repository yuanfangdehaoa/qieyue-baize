#!/usr/bin/env bash

###=============================================================================
### @doc 关闭中心服
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Center [-f]"
}

if [ $# -lt 1 ]; then
	usage
fi

Center=${1}

check_center ${Center}

confirm_ansible $@

playbook stop_server.yml ${DIR_HOSTS}/center.hosts \
	-e servers=${Center} \
	-e backup_path=${DIR_BACKUP}
