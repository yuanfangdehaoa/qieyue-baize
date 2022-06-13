#!/usr/bin/env bash

###=============================================================================
### @doc 生成sys.config
###=============================================================================

source ../comm/env.sh
source ../comm/util.sh

function usage()
{
    fatal "usage: $0 WorkDir ServType"
}

if [ $# -ne 2 ]; then
    usage
fi

WorkDir=$(echo ${1} | sed 's/\/$//g')
ServType=${2}

if [ ! -d ${WorkDir} ]; then
    fatal "${WorkDir}目录不存在"
fi

check_servtype ${ServType}

case "$(basename ${WorkDir})" in
    "develop" )
        ServID=1
        ServPort=9001
        WebPort=9101
        ;;
    "release" )
        ServID=2
        ServPort=9002
        WebPort=9102
        ;;
    "banhao" )
        ServID=3
        ServPort=9003
        WebPort=9103
        ;;
    "prepare" )
        ServID=4
        ServPort=9004
        WebPort=9104
        ;;
    "produce" )
        ServID=5
        ServPort=9005
        WebPort=9105
        ;;
esac

SysConfig=${WorkDir}/server/etc/sys.config

/bin/cp ${SysConfig}.src ${SysConfig}

GameID=${GAME_ID}
GameCode=${GAME_CODE}
PlatName=xingwan
PlatID=10
ServID=$(echo $[${PlatID} * 100000 + ${ServID}])
ServHost=$(ifconfig eth0 | grep inet | cut -d : -f 2 | cut -d " " -f 1)
Token="00f0e38dddbe24b3744778ab879c8f12"
Cookie="y4OY1!26X2bO*zy%pC$f*M#eWyVf^P%U"
Center="undefined"
AdminHost="http://192.168.31.100"
JunHaiUpload=""
VirtualHost='<<"xw01">>'
RabbitHost="192.168.31.100"
UserName='<<"admin">>'
Password='<<"123456">>'

sed -i "s|{{ game_id }}|${GameID}|g" ${SysConfig}
sed -i "s|{{ game_name }}|${GameCode}|g" ${SysConfig}
sed -i "s|{{ plat_name }}|${PlatName}|g" ${SysConfig}
sed -i "s|{{ plat_id }}|${PlatID}|g" ${SysConfig}
sed -i "s|{{ serv_type }}|${ServType}|g" ${SysConfig}
sed -i "s|{{ serv_id }}|${ServID}|g" ${SysConfig}
sed -i "s|{{ serv_host }}|${ServHost}|g" ${SysConfig}
sed -i "s|{{ serv_port }}|${ServPort}|g" ${SysConfig}
sed -i "s|{{ open_time }}|{{2018,8,8},{8,8,8}}|g" ${SysConfig}
sed -i "s|{{ token }}|${Token}|g" ${SysConfig}
sed -i "s|{{ cookie }}|${Cookie}|g" ${SysConfig}
sed -i "s|{{ center }}|${Center}|g" ${SysConfig}
sed -i "s|{{ admin_host }}|${AdminHost}|g" ${SysConfig}
sed -i "s|{{ junhai_upload }}|${JunHaiUpload}|g" ${SysConfig}
sed -i "s|{{ web_port }}|${WebPort}|g" ${SysConfig}
sed -i "s|{{ virtual_host }}|${VirtualHost}|g" ${SysConfig}
sed -i "s|{{ rabbit_host }}|${RabbitHost}|g" ${SysConfig}
sed -i "s|{{ username }}|${UserName}|g" ${SysConfig}
sed -i "s|{{ password }}|${Password}|g" ${SysConfig}

print "配置生成成功"
