#########################################################################
# File Name: Run.sh
# Author: HouJP
# mail: peng_come_on@126.com
# Created Time: 六 11/ 1 20:16:20 2014
#########################################################################
#! /bin/sh

PATH_PRE="`pwd`"
PATH_NOW="`dirname $0`"
cd ${PATH_NOW}
source ../conf/crawler.conf
source Utils.sh
cd ${PATH_PRE}

set -o pipefail
set -x

function StartUpCrawler() {
	local round="`date +\"%Y-%m-%d-%H\"`"
	local ret=

	mkdir -p ${LOG_PATH}/${round}
	mv ${ALLOW_RUN_FLAG}.bak ${ALLOW_RUN_FLAG}
	ret=$?
	if [ ${ret} -ne 0 ]; then
		return -1
	fi
	#nohup bash ${BIN_CRAWNEWSSCHEDULE} &> ${LOG_PATH}/${round}/Run.log &
	nohup bash ${BIN_CRAWNEWSSCHEDULE} &
	ret=$?
	if [ ${ret} -ne 0 ]; then
		return -1
	fi
	return 0
}

function ShutDownCrawler() {
	local ret=

	mv ${ALLOW_RUN_FLAG} ${ALLOW_RUN_FLAG}.bak
	ret=$?
	if [ ${ret} -ne 0 ]; then
		return -1
	fi
	return 0
}

function CleanAll() {
	local ret=

	rm -rf ${FLAG_DOWNLOADED_PATH}/*
	rm -rf ${FLAG_SCHEDULE_PATH}/*
	rm -rf ${DATA_PATH}/*

	return 0
}

function CountData() {
	sh "${BIN_COUNTDATA}"	
}

function Run() {
	if [ $# -ne 1 ]; then
		LOG "命令参数错误，请检查输入！"
		return -1
	fi

	local cmd="${1}"
	local ret=

	if [ ${cmd} == "start" ]; then
		LOG "准备启动爬虫..."
		StartUpCrawler
		ret=$?
		if [ ${ret} -ne 0 ]; then
			LOG "爬虫启动失败，请检查配置！"
		else
			LOG "爬虫已启动！"
		fi
	elif [ ${cmd} == "stop" ]; then
		LOG "爬虫关闭中..."
		ShutDownCrawler
		ret=$?
		if [ ${ret} -ne 0 ]; then
			LOG "爬虫关闭失败，请检查配置！"
		else
			LOG "爬虫已关闭！"
		fi
	elif [ ${cmd} == "cleanall" ]; then
		LOG "清除全部数据中..."
		CleanAll
		ret=$?
		if [ ${ret} -ne 0 ]; then
			LOG "清除数据失败！"
		else
			LOG "数据全部清除！"
		fi
	elif [ ${cmd} == "count" ]; then
		CountData
	else
		LOG "未知命令，请检查输入！"
	fi
}

Run ${1}
