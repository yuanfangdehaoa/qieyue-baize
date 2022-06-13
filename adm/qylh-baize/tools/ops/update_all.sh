#!/usr/bin/env bash

###=============================================================================
### @doc 热更所有服务端
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 PkgTag Center [-f]"
}

if [ $# -lt 2 ]; then
	usage
fi

PkgTag=${1}
Center=${2}

check_center ${Center}

Package=$(pkg_server_patch ${PkgTag})

if [ ! -f ${Package} ]; then
	fatal "${Package}不存在"
fi

confirm_ansible $@

# 更新游戏服
for Platform in $(get_platforms ${Center}); do
	playbook update_server.yml ${DIR_HOSTS}/${Platform}/server.hosts \
		-e servers=${Platform} \
		-e pkg=${Package}
done

# 更新跨服
playbook update_server.yml ${DIR_HOSTS}/cross.hosts \
	-e servers=${Center} \
	-e pkg=${Package}

# 更新中心服
playbook update_server.yml ${DIR_HOSTS}/center.hosts \
	-e servers=${Center} \
	-e pkg=${Package}
