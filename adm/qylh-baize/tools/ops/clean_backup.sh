#!/usr/bin/env bash

###=============================================================================
### @doc 清理Mnesia备份
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0"
}

cd ${DIR_TOOLS}/ops/

./sync_hosts.sh

playbook clean_backup.yml hosts/ops.hosts \
	-e servers=lan_ops \
	-e backup_path=${DIR_BACKUP} \
	-e days_ago=3d
