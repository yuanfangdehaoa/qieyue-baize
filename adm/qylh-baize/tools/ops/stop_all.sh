#!/usr/bin/env bash

###=============================================================================
### @doc 关闭服务器 TODO
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

# 停止游戏服
for Platform in $(get_platforms ${Center}); do
	playbook stop_server.yml ${DIR_HOSTS}/${Platform}/server.hosts \
		-e servers=${Platform} \
		-e backup_path=${DIR_BACKUP}
done

# 停止跨服
playbook stop_server.yml ${DIR_HOSTS}/cross.hosts \
	-e servers=${Center} \
	-e backup_path=${DIR_BACKUP}

# 停止中心服
playbook stop_server.yml ${DIR_HOSTS}/center.hosts \
	-e servers=${Center} \
	-e backup_path=${DIR_BACKUP}
