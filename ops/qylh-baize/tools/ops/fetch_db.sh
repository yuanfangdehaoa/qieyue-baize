#!/usr/bin/env bash

###=============================================================================
### @doc 备份游戏服的最新数据库文件回运维机
###=============================================================================
source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Platform Servers [-f]"
}

if [ $# -lt 2 ]; then
	usage
fi

Platform=${1}
Servers0=${2}

check_platform ${Platform}

Servers=$(make_hosts ${Platform} ${Servers0})

confirm_ansible $@

Host=${DIR_HOSTS}/${Platform}/server.hosts

if [ ${Servers0} == 'all' ]; then
  Servers=${Platform}
fi

playbook fetch_db.yml ${Host} \
  -e servers=${Servers} \
  -e dir_backup=${DIR_BACKUP}














