#!/usr/bin/env bash

###=============================================================================
### @doc 同步主机清单
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0"
}

playbook sync_directory.yml hosts/ops.hosts \
	-e machines=wan_adm \
	-e src=${DIR_ADMIN}/storage/app/hosts/ \
	-e dst=${DIR_HOSTS} \
	-e mode=pull \
	-e own=root \
	-e grp=root
