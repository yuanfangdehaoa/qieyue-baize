#!/usr/bin/env bash

###=============================================================================
### @doc 将运维机器的lastest db备份文件推送到游戏服
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

playbook copy_db.yml ${Host} \
  -e servers=${Servers} \
  -e dir_backup=${DIR_BACKUP}














