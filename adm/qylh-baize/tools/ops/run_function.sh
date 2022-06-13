#!/usr/bin/env bash

###=============================================================================
### @doc 执行函数
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Target Center Module Method [-f]"
}

if [ $# -lt 4 ]; then
	usage
fi

Target=${1}
Center=${2}
Module=${3}
Method=${4}

if [ "${Target}" != "all" ]; then
	check_servtype ${Target}
fi
check_center ${Center}

confirm_ansible $@

# 游戏服节点执行函数
if [ "${Target}" == "server" -o "${Target}" == "all" ]; then
	for Platform in $(get_platforms ${Center}); do
		playbook run_function.yml ${DIR_HOSTS}/${Platform}/server.hosts \
			-e servers=${Platform} \
			-e module=${Module} \
			-e method=${Method}
	done
fi

# 中心服节点执行函数
if [ "${Target}" == "center" -o "${Target}" == "all" ]; then
	playbook run_function.yml ${DIR_HOSTS}/center.hosts \
		-e servers=${Center} \
		-e module=${Module} \
		-e method=${Method}
fi

# 跨服节点执行函数
if [ "${Target}" == "cross" -o "${Target}" == "all" ]; then
	playbook run_function.yml ${DIR_HOSTS}/cross.hosts \
		-e servers=${Center} \
		-e module=${Module} \
		-e method=${Method}
fi
