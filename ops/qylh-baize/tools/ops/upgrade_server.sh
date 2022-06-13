#!/usr/bin/env bash

###=============================================================================
### @doc 升级所有服务端
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Version PkgTag Center [-f]"
}

if [ $# -lt 3 ]; then
	usage
fi

Version=${1}
PkgTag=${2}
Center=${3}

check_major_version ${Version}
check_center ${Center}

Package=$(pkg_server_release ${Version} ${PkgTag})

if [ ! -f ${Package} ]; then
	fatal "${Package}不存在"
fi

confirm_ansible $@

# 停服
./stop_all.sh ${Center} -f

# 升级游戏服
for Platform in $(get_platforms ${Center}); do
	playbook upgrade_server.yml ${DIR_HOSTS}/${Platform}/server.hosts \
		-e servers=${Platform} \
		-e pkg=${Package} \
		-e backup_path=${DIR_BACKUP}
done

# 升级跨服
playbook upgrade_server.yml ${DIR_HOSTS}/cross.hosts \
	-e servers=${Center} \
	-e pkg=${Package} \
	-e backup_path=${DIR_BACKUP}

# 升级中心服
playbook upgrade_server.yml ${DIR_HOSTS}/center.hosts \
	-e servers=${Center} \
	-e pkg=${Package} \
	-e backup_path=${DIR_BACKUP}

# 启动
./start_all.sh ${Center} -f
