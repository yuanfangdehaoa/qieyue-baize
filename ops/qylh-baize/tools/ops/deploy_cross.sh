#!/usr/bin/env bash

###=============================================================================
### @doc 部署并配置跨服
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Version PkgTag Crosses [-f]"
}

if [ $# -lt 3 ]; then
	usage
fi

Version=${1}
PkgTag=${2}
Crosses=${3}

check_major_version ${Version}

Package=$(pkg_server_release ${Version} ${PkgTag})
Crosses=$(make_hosts cross ${Crosses})

confirm_ansible $@

playbook deploy_server.yml ${DIR_HOSTS}/cross.hosts \
	-e servers=${Crosses} \
	-e pkg=${Package}
