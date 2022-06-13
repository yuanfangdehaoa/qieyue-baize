#!/usr/bin/env bash

###=============================================================================
### @doc 部署并配置游戏服
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Version PkgTag Platform Servers [-f]"
}

if [ $# -lt 4 ]; then
	usage
fi

Version=${1}
PkgTag=${2}
Platform=${3}
Servers0=${4}

check_major_version ${Version}
check_platform ${Platform}

Package=$(pkg_server_release ${Version} ${PkgTag})
Servers=$(make_hosts ${Platform} ${Servers0})

confirm_ansible $@

playbook deploy_server.yml ${DIR_HOSTS}/${Platform}/server.hosts \
	-e servers=${Servers} \
	-e pkg=${Package}

./start_server.sh ${Platform} ${Servers0} -f
