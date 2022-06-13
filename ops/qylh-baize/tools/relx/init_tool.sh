#!/usr/bin/env bash

###=============================================================================
### @doc 初始化运维工具
###=============================================================================
source ../comm/util.sh

function usage()
{
    fatal "usage: $0 GameCode SvnInner SvnOuter AdmWan AdmLan OpsWan OpsLan CdnWan CdnLan SSHPass TimeZone AdmHost RabHost JhUpload"
}

if [ $# -ne 14 ]; then
    usage
fi

GameCode=${1}
SvnInner=${2}
SvnOuter=${3}
AdmWan=${4}
AdmLan=${5}
OpsWan=${6}
OpsLan=${7}
CdnWan=${8}
CdnLan=${9}
SSHPass=${10}
TimeZone=${11}
AdmHost=${12}
RabHost=${13}
JhUpload=${14}

DIR_TOOLS=$(cd $(dirname $0); cd ..; pwd)

FileEnv=${DIR_TOOLS}/comm/env.sh
FileOps=${DIR_TOOLS}/ops/playbook/hosts/ops.hosts
FileVar=${DIR_TOOLS}/ops/playbook/vars/common.yml

# env.sh
/bin/cp ${DIR_TOOLS}/conf/env.sh.src ${FileEnv}
sed -i "s|{{ GAME_CODE }}|${GameCode}|g" ${FileEnv}
sed -i "s|{{ SVN_INNER_ROOT }}|${SvnInner}|g" ${FileEnv}
sed -i "s|{{ SVN_OUTER_ROOT }}|${SvnOuter}|g" ${FileEnv}

# ops.hosts
/bin/cp ${DIR_TOOLS}/conf/ops.hosts.src ${FileOps}
sed -i "s|{{ WAN_ADM }}|${AdmWan}|g" ${FileOps}
sed -i "s|{{ LAN_ADM }}|${AdmLan}|g" ${FileOps}
sed -i "s|{{ WAN_OPS }}|${OpsWan}|g" ${FileOps}
sed -i "s|{{ LAN_OPS }}|${OpsLan}|g" ${FileOps}
sed -i "s|{{ WAN_CDN }}|${CdnWan}|g" ${FileOps}
sed -i "s|{{ LAN_CDN }}|${CdnLan}|g" ${FileOps}

# common.yml
/bin/cp ${DIR_TOOLS}/conf/common.yml.src ${FileVar}
sed -i "s|{{ SSH_PASS }}|${SSHPass}|g" ${FileVar}
sed -i "s|{{ TIMEZONE }}|${TimeZone}|g" ${FileVar}
sed -i "s|{{ ADMIN_HOST }}|${AdmHost}|g" ${FileVar}
sed -i "s|{{ RABBIT_HOST }}|${RabHost}|g" ${FileVar}
sed -i "s|{{ JH_UPLOAD }}|${JhUpload}|g" ${FileVar}
