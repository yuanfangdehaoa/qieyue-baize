#!/usr/bin/env bash

###=============================================================================
### @doc 还原游戏服最后备份的数据库文件 lastest.tar.gz 是目标机器上的lastest.tar.gz文件
### 如果是迁移服务器的时候使用，先停服然后执行fetch_db命令备份lastest文件回ops机器，再部署新服，停服，执行推送脚本copy_db推送ops的lastest文件到目标机器覆盖，然后再执行本脚本回滚数据库即可
###=============================================================================
source ../comm/env.sh
source ../comm/util.sh

## 用法说明
function usage()
{
  fatal "usage: $0 Platform ServerID [-f]"
}

## 判断参数个数
if [ $# -lt 2 ]; then
  usage
fi

## 获取参数 Platform 平台 ， 目标服务器ID列表
Platform=${1}
Servers0=${2}

## 检查平台是否存在, 在Hosts目录下的Platform.txt匹配查找
check_platform $Platform

## 组合平台和服务器ID获得目标数组
Servers=$(make_hosts ${Platform} ${Servers0})

## 操作前确认， 顺便同步最新的hosts文件
confirm_ansible $@

Hosts=${DIR_HOSTS}/${Platform}/server.hosts

playbook restore_db.yml ${Hosts} \
  -e servers=${Servers} \
  -e dir_backup=${DIR_BACKUP}
