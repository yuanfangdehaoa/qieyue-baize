#!/usr/bin/env bash

###=============================================================================
### @doc 合服
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
SUIDs=$(make_suids ${Host} ${Servers})

echo "合服列表:"${SUIDs}

# 停服、备份
playbook merge_prepare.yml ${Host} \
	-e servers=${Servers} \
	-e backup_path=${DIR_BACKUP} \
	-e merge_path=${DIR_MERGE}

ServerArr=($(echo "${Servers}" | sed 's/,/ /g'))
LastIndex=$(expr ${#ServerArr[*]} - 1)
LastServer=${ServerArr[${LastIndex}]}

MachineID=$(grep -E "^\b${LastServer}\b" ${Host} | grep -E -o "machine_id=\S+" | cut -d"=" -f2)
DstMachine=machine_${MachineID}

for Server in ${ServerArr}; do
	if [ "${Server}" != "${LastServer}" ]; then
		ServerID=$(grep -E "^\b${Server}\b" ${Host} | grep -E -o "serv_id=\S+" | cut -d"=" -f2)
		MachineID=$(grep -E "^\b${Server}\b" ${Host} | grep -E -o "machine_id=\S+" | cut -d"=" -f2)

		BackupFile=${DIR_MERGE}/data.${ServerID}
		SrcMachine=machine_${MachineID}

		echo SrcMachine:${SrcMachine}
		echo DstMachine:${DstMachine}

		if [ "${SrcMachine}" != "${DstMachine}" ]; then
			# 拉取数据库文件到运维机
			playbook fetch_file.yml ${DIR_HOSTS}/machine.hosts \
				-e machines=${SrcMachine} \
				-e src=${BackupFile} \
				-e dst=${BackupFile}

			# 同步数据库文件到游戏服
			playbook copy_file.yml ${DIR_HOSTS}/machine.hosts \
				-e machines=${DstMachine} \
				-e path=${DIR_MERGE} \
				-e src=${BackupFile} \
				-e dst=${BackupFile} \
				-e own=root \
				-e grp=root
		fi
	fi
done

# 开始合服
playbook merge_server.yml ${Host} \
	-e servers=${LastServer} \
	-e suids=${SUIDs}

ZoneArr=($(echo "${Servers0}" | sed 's/,/ /g'))
LastIdx=$(expr ${#ZoneArr[*]} - 1)
MergeTo=${ZoneArr[${LastIdx}]}

# 启动服务器
./start_server.sh ${Platform} ${MergeTo} -f
