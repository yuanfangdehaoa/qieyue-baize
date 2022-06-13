#!/usr/bin/env bash

###=============================================================================
### @doc 更新所有的数据库
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Center Version [-f]"
}

if [ $# -lt 2 ]; then
	usage
fi

Center=${1}
Version=${2}

check_center ${Center}
check_major_version ${Version}

confirm_ansible $@

# 更新游戏服数据库
for Platform in $(get_platforms ${Center}); do
	playbook migrate_mnesia.yml ${DIR_HOSTS}/${Platform}/server.hosts \
		-e servers=${Platform} \
		-e version=${Version}
done


# 更新中心服数据库
playbook migrate_mnesia.yml ${DIR_HOSTS}/center.hosts \
	-e servers=${Center} \
	-e version=${Version}