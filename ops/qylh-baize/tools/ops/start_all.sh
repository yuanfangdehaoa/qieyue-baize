#!/usr/bin/env bash

###=============================================================================
### @doc 启动服务器
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

# 启动中心服
playbook start_server.yml ${DIR_HOSTS}/center.hosts \
	-e servers=${Center}

# 启动跨服
playbook start_server.yml ${DIR_HOSTS}/cross.hosts \
	-e servers=${Center}

# 启动游戏服
for Platform in $(get_platforms ${Center}); do
	playbook start_server.yml ${DIR_HOSTS}/${Platform}/server.hosts \
		-e servers=${Platform}
done
