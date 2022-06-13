#!/usr/bin/env bash

DIR_TOOLS=$(cd $(dirname $0); cd ..; pwd)

svn up ${DIR_TOOLS}

chmod a+x ${DIR_TOOLS}/relx/*.sh
chmod a+x ${DIR_TOOLS}/ops/*.sh
chmod a+x ${DIR_TOOLS}/comm/*.sh

DIR_DATA=/data

GAME_CODE=qylh-baize

GAME_ID=217

## 后台安装目录
DIR_ADMIN=${DIR_DATA}/admin

## 数据库备份目录
DIR_BACKUP=${DIR_DATA}/backup

## cdn热更目录
DIR_CDN=${DIR_DATA}/cdn

## ansible主机清单目录
DIR_HOSTS=${DIR_DATA}/${GAME_CODE}/hosts

## tar包根目录
DIR_PKG=${DIR_DATA}/pkg/${GAME_CODE}

## 合服目录
DIR_MERGE=${DIR_DATA}/merge

## 开发服目录
DIR_DEVELOP=${DIR_DATA}/${GAME_CODE}/develop
## 稳定服目录
DIR_RELEASE=${DIR_DATA}/${GAME_CODE}/release
## 生产服目录
DIR_PRODUCE=${DIR_DATA}/${GAME_CODE}/produce

## svn 路径
SVN_INNER_ROOT=svn://172.27.0.9/xw01

if [ "${GAME_CODE}" == "qylh-jh" -o "${GAME_CODE}" == "qylh-yg" ]; then
	SVN_INNER_DEVELOP=${SVN_INNER_ROOT}
	SVN_INNER_RELEASE=${SVN_INNER_ROOT}/branch/release
	SVN_INNER_STABLES=${SVN_INNER_ROOT}/branch/stables
else
	SVN_INNER_DEVELOP=${SVN_INNER_ROOT}/develop
	SVN_INNER_RELEASE=${SVN_INNER_ROOT}/release
	SVN_INNER_STABLES=${SVN_INNER_ROOT}/branch
fi

SVN_OUTER_ROOT=svn://42.193.1.56/xw01
SVN_OUTER_DEVELOP=${SVN_OUTER_ROOT}/develop
SVN_OUTER_RELEASE=${SVN_OUTER_ROOT}/release
SVN_OUTER_STABLES=${SVN_OUTER_ROOT}/branch

case "${GAME_CODE}" in
	"qylh-jh" )
		CONVERT_TO="never"
		SUB_CONFIG="normal"
		;;
	"qylh-yg" )
		CONVERT_TO="never"
		SUB_CONFIG="normal"
		;;
	"qylh-ft" )
		CONVERT_TO="zh-hk"
		SUB_CONFIG="twft"
		;;
	"qylh-tw" )
		CONVERT_TO="thai"
		SUB_CONFIG="twtw"
		;;
	"qylh-en" )
		CONVERT_TO="en"
		SUB_CONFIG="twen"
		;;
	"qylh-kr" )
		CONVERT_TO="kr"
		SUB_CONFIG="twkr"
		;;
	"qylh-xwen" )
		CONVERT_TO="en"
		SUB_CONFIG="twen"
		;;
  "qylh-vn" )
		CONVERT_TO="vn"
		SUB_CONFIG="r2vn"
		;;
  "qylh-baize" )
		CONVERT_TO="never"
		SUB_CONFIG="normal"
		;;
esac
