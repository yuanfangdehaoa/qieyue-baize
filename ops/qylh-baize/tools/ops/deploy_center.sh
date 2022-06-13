#!/usr/bin/env bash

###=============================================================================
### @doc 部署并配置中心服
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

check_center ${Center}
check_major_version ${Version}

Package=$(pkg_server_release ${Version} ${PkgTag})
echo ${Package}
echo ${Center}
confirm_ansible $@

playbook deploy_server.yml ${DIR_HOSTS}/center.hosts \
	-e servers=${Center} \
	-e pkg=${Package}
