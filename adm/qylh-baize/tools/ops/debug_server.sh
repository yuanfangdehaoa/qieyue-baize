#!/usr/bin/env bash

###=============================================================================
### @doc 调试游戏服
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
	fatal "usage: $0 Platform Server"
}

if [ $# -ne 2 ]; then
	usage
fi

Platform=${1}
Server=${2}

check_platform ${Platform}

HostFile=${DIR_HOSTS}/${Platform}/server.hosts

SUID=$(grep -E "^\b${Platform}_${Server}\b" ${HostFile} | grep -E -o "serv_id=\S+" | cut -d"=" -f2)
Host=$(grep -E "^\b${Platform}_${Server}\b" ${HostFile} | grep -E -o "serv_host=\S+" | cut -d"=" -f2)
Path=$(grep -E "^\b${Platform}_${Server}\b" ${HostFile} | grep -E -o "serv_path=\S+" | cut -d"=" -f2)

Name=qylh_server_${Platform}_${SUID}
MyIP=$(ifconfig eth0 | grep inet | cut -d : -f 2 | cut -d " " -f 1)

erl -setcookie ''\''y4OY1!26X2bO*zy%pC$f*M#eWyVf^P%U'\''' -name debug_${Name}@${MyIP} -remsh ${Name}@${Host}
