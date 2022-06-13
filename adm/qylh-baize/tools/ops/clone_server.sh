#!/usr/bin/env bash

###=============================================================================
### @doc 克隆服务器
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Platform ServerID WorkDir [-f]"
}

if [ $# -lt 3 ]; then
	usage
fi

Platform=${1}
ServerID=${2}
WorkDir=${3}

check_platform ${Platform}

Server=$(make_hosts ${Platform} ${ServerID})

confirm_ansible $@

Hosts=${DIR_HOSTS}/${Platform}/server.hosts

SUID=$(grep -w ${Server} ${Hosts} | grep -E -o "serv_id=\w+" | cut -d"=" -f2)

Backup=server-${Platform}-${SUID}-lastest.tar.gz

playbook clone_server.yml ${DIR_HOSTS}/${Platform}/server.hosts \
	-e server=${Server} \
	-e pkg=${DIR_BACKUP}/${Backup} \
	-e dst=${WorkDir}/

rm -f ${WorkDir}/Backup

cd ${WorkDir}

sh xctl stop

sleep 5

rm -f data/*

sh xctl schema

mv -f data/schema.DAT .

rm -f data/*

tar -xzf ${Backup} -C data/

mv -f schema.DAT data/

sleep 5

sh xctl start
