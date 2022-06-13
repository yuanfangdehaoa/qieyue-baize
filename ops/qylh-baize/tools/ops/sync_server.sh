#!/usr/bin/env bash

###=============================================================================
### @doc 同步后端
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 [-f]"
}

confirm_ansible $@

playbook sync_directory.yml ${DIR_HOSTS}/machine.hosts \
	-e machines=all \
	-e src=${DIR_PKG}/ \
	-e dst=${DIR_PKG} \
	-e mode=push \
	-e own=root \
	-e grp=root