#!/usr/bin/env bash

###=============================================================================
### @doc 备份Mnesia
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0"
}

cd ${DIR_TOOLS}/ops/

./sync_hosts.sh

for Center in $(get_centers); do
	./backup_mnesia.sh ${Center} -f
done

if [ "$(date +%H)" == "03" ]; then
	# 每天3点清理游戏服7天前的备份
	playbook clean_backup.yml ${DIR_HOSTS}/machine.hosts \
		-f 1 \
		-e servers=all \
		-e backup_path=${DIR_BACKUP} \
		-e days_ago=7d

	# 每天3点清理运维服3天前的备份
	playbook clean_backup.yml hosts/ops.hosts \
		-e servers=lan_ops \
		-e backup_path=${DIR_BACKUP} \
		-e days_ago=3d
fi
