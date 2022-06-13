#!/usr/bin/env bash

###=============================================================================
### @doc 备份Mnesia
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

# 备份游戏服
for Platform in $(get_platforms ${Center}); do
	playbook backup_mnesia.yml ${DIR_HOSTS}/${Platform}/server.hosts \
		-f 1 \
		-e servers=${Platform} \
		-e backup_path=${DIR_BACKUP}
done

# 备份中心服
playbook backup_mnesia.yml ${DIR_HOSTS}/center.hosts \
	-f 1 \
	-e servers=${Center} \
	-e backup_path=${DIR_BACKUP}
