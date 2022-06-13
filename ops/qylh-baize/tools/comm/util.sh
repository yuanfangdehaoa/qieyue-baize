#!/usr/bin/env bash

function print()
{
    echo -ne "\e[32m"
    echo ${1}
    echo -ne "\e[0m"
}

function warn()
{
    echo -ne "\e[33m"
    echo ${1}
    echo -ne "\e[0m"
}

function fatal()
{
    echo -ne "\e[31m"
    echo ${1}
    echo -ne "\e[0m"
    exit 1
}

## 判断是否列表成员
function is_member()
{
    local Elem=${1}
    shift
    local List=$@
    for e in ${List}; do
        if [ "${e}" == "${Elem}" ]; then
            return 0
        fi
    done
    return 1
}

function is_bool()
{
    if [ "${1}" == "true" -o "${1}" == "false" ]; then
        return 0
    else
        return 1
    fi
}

## 执行 ansible-playbook
function playbook()
{
    cd ${DIR_TOOLS}/ops/playbook
    local Playbook=${1}
    local HostsFile=${2}
    if [ ! -f ${HostsFile} ]; then
        warn "${HostsFile}不存在"
        cd - 1> /dev/null
        return
    fi
    shift 2
    ansible-playbook ${Playbook} -i ${HostsFile} $@
    maybe_fail "操作失败"
    cd - 1> /dev/null
}

## 中心服列表
function get_centers()
{
    cat ${DIR_HOSTS}/platforms.txt | grep -v undefined | cut -d' ' -f3 | sort -n | uniq
}

function is_center()
{
    return $(is_member ${1} $(get_centers))
}

## 检查分组
function check_center()
{
    if ! $(is_center ${1}); then
        fatal "invalid center: ${1}"
    fi
}

## 平台列表
function get_platforms()
{
    if [ $# -eq 0 ]; then
        cat ${DIR_HOSTS}/platforms.txt | cut -d' ' -f1
    else
        local Center=${1}
        cat ${DIR_HOSTS}/platforms.txt | grep "${Center} " | cut -d' ' -f1
    fi
}

function is_platform()
{
    return $(is_member ${1} $(get_platforms))
}

## 检查平台
function check_platform()
{
    if ! $(is_platform ${1}); then
        fatal "invalid platform: ${1}"
    fi
}

function is_servtype()
{
    return $(is_member ${1} "server center cross")
}

## 检查服务器类型
function check_servtype()
{
    if ! $(is_servtype ${1}); then
        fatal "invalid server type: ${1}"
    fi
}

function is_branch()
{
    return $(is_member ${1} "develop release bt")
}

## 检查分支
function check_branch()
{
    if ! $(is_branch ${1}); then
        fatal "invalid branch: ${1}"
    fi
}

## 检查svn路径
function check_svnurl()
{
    svn info ${1} >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        fatal "invalid svn url: ${1}"
    fi
}

## 检查版本号
function check_major_version()
{
    if [ "$(echo "${1}" | grep -P '^\d+\.\d+$')" == "" ]; then
        fatal "invalid version: ${1}"
    fi
}

function check_full_version()
{
    if [ "$(echo "${1}" | grep -P '^\d+\.\d+\.\d+$')" == "" ]; then
        fatal "invalid version: ${1}"
    fi
}

function is_ostype()
{
    return $(is_member ${1} "android ios")
}

## 检查手机操作系统
function check_ostype()
{
    if ! $(is_ostype ${1}); then
        fatal "invalid ostype: ${1}"
    fi
}

## 检查sys.config是否存在
function check_config()
{
    local DstDir=${1}
    local Config=${DstDir}/server/etc/sys.config
    if [ ! -f ${Config} ]; then
        fatal "${Config} not exist"
    fi
}

function check_dir()
{
    if [ ! -d ${1} ]; then
        fatal "${1}目录不存在"
    fi
}

## 是否包含标签
function is_contain()
{
    local Flag=${1}
    shift
    if [ "$(echo $@ | grep -E '\'${Flag})" == "" ]; then
        return 1
    else
        return 0
    fi
}

## 操作前确认
function confirm_ansible()
{
    if $(is_contain -f $@); then
        ./sync_hosts.sh 1>/dev/null
        return
    fi
    echo -ne "\e[33m"
    read -p "确认操作?[yes/no]" Input
    echo -ne "\e[0m"
    Input=$(echo "${Input}" | tr 'a-z' 'A-Z')
    if [ "${Input}" != "YES" ]; then
        exit 1
    fi
    ./sync_hosts.sh 1>/dev/null
}

## 覆盖前确认
function confirm_override()
{
    local Target=${1}
    if $(is_contain -f $@); then
        return
    fi
    echo -ne "\e[33m"
    read -p "${Target}已存在，是否覆盖?[yes/no]:" Input
    echo -ne "\e[0m"
    Input=$(echo "${Input}" | tr 'a-z' 'A-Z')
    if [ "${Input}" != "YES" ]; then
        exit 1
    fi
}

function maybe_override_file()
{
    local File=${1}
    if [ -f ${File} ]; then
        confirm_override $@
    fi
}

function maybe_override_dir()
{
    local Dir=${1}
    if [ -d ${Dir} ]; then
        confirm_override $@
    fi
}

## 操作可能失败
function maybe_fail()
{
    if [ $? -ne 0 ]; then
        fatal ${1}
    fi
}

function make_hosts()
{
    Prefix=${1}
    shift
    IDList=$(echo "$@" | sed 's/ //g' | sed 's/,/ /g')

    for IDInfo in ${IDList}; do
        if [ "$(echo ${IDInfo} | grep '-')" == "" ]; then
            ID=${IDInfo}
            Hosts="${Hosts},${Prefix}_${ID}"
        else
            MinID=$(echo ${IDInfo} | cut -d"-" -f1)
            MaxID=$(echo ${IDInfo} | cut -d"-" -f2)
            for ID in $(seq ${MinID} ${MaxID}); do
                Hosts="${Hosts},${Prefix}_${ID}"
            done
        fi
    done
    echo "${Hosts}" | sed 's/^,//g'
}

function make_suids()
{
    Host=${1}
    shift
    Servers=$(echo "$@" | sed 's/ //g' | sed 's/,/ /g')
    for Serv in ${Servers}; do
        SUID=$(grep -E "^\b${Serv}\b" ${Host} | grep -E -o "serv_id=\w+" | cut -d"=" -f2)
        SUIDs="${SUIDs},${SUID}"
    done
    echo "${SUIDs}" | sed 's/^,//g'
}

## 服务端版本包
function pkg_server_release()
{
    local Version=${1}
    local PkgTag=${2}
    echo ${DIR_PKG}/${Version}/server-pack-${PkgTag}.tar.gz
}

## 服务端更新包
function pkg_server_patch()
{
    local PkgTag=${1}
    echo ${DIR_PKG}/server-patch-${PkgTag}.tar.gz
}

function txt_version_client()
{
    local WorkDir=${1}
    echo ${WorkDir}/client/config/version.txt
}

function txt_version_server()
{
    local WorkDir=${1}
    echo ${WorkDir}/server/etc/version.txt
}

function current_version()
{
    local VsnFile=${1}
    echo $(head -1 ${VsnFile} | cut -d. -f1-2)
}

function current_revision()
{
    local VsnFile=${1}
    echo $(head -1 ${VsnFile} | cut -d. -f3)
}

## 获取最新修订号
function lastest_revision()
{
    local DstDir=${1}
    local SvnUrl=$(svn info ${DstDir} | grep -E "^Repository Root" | cut -d" " -f3)
    echo $(svn info ${SvnUrl} | grep -E "^Revision" | cut -d" " -f2)
}

function update_client_revision()
{
    local WorkDir=${1}
    local VsnFile=$(txt_version_client ${WorkDir})
    local NewRev=$(lastest_revision ${WorkDir}/client/config)
    local NewVsn=$(head -1 ${VsnFile} | cut -d. -f1-2).${NewRev}
    echo ${NewVsn} > ${VsnFile}
    echo ${NewVsn}
}

function update_server_revision()
{
    local WorkDir=${1}
    local VsnFile=$(txt_version_server ${WorkDir})
    local NewRev=$(lastest_revision ${WorkDir}/server)
    local NewVsn=$(head -1 ${VsnFile} | cut -d. -f1-2).${NewRev}
    echo ${NewVsn} > ${VsnFile}
    echo ${NewVsn}
}

## 备份文件后缀
function backup_suffix()
{
    echo $(date +%Y%m%d%H)
}

function maybe_upload()
{
    local PkgType=${1}
    local Package=${2}
    shift
    if $(is_contain -u $@); then
        cd ${DIR_TOOLS}/ops
        ./upload_package.sh ${PkgType} ${Package}
    fi
}
