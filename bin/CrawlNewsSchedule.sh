#########################################################################
# File Name: CrawlNewsSchedule.sh
# Author: HouJP
# mail: peng_come_on@126.com
# Created Time: 三 10/29 21:49:50 2014
#########################################################################
#! /bin/bash

PATH_PRE="`pwd`"
PATH_NOW="`dirname $0`"
cd ${PATH_NOW}
source ../conf/crawler.conf
source CrawlNewsProcess.sh
source Utils.sh
cd ${PATH_PRE}

set -o pipefail
set -x

g_current_round=""
g_current_task=""
g_current_depth=
g_current_seed=
g_current_seed_id=
g_failed_time=

function InitEnv() {
	mkdir -p "${FLAG_CONCURRENCY_PATH}"
	mkdir -p "${FLAG_SCHEDULE_PATH}"
	mkdir -p "${FLAG_SCHEDULE_BAK_PATH}"
	mkdir -p "${FLAG_DOWNLOADED_PATH}"

	mkdir -p "${DATA_PATH}/${g_current_round}"
}

function InitRun() {
	local round=${1}

	touch ${RUNNING_FLAG}
	echo "${round}" > ${RUNNING_FLAG}
	for SEED_URL in ${SEED_URLS[@]}
	do
		mkdir -p "${FLAG_SCHEDULE_PATH}/${SEED_URL//\//|}"
		touch "${FLAG_SCHEDULE_PATH}/${SEED_URL//\//|}/${SEED_URL//\//|}"
		echo "0" > "${FLAG_SCHEDULE_PATH}/${SEED_URL//\//|}/${SEED_URL//\//|}"

		mkdir -p "${DATA_PATH}/${g_current_round}/${SEED_URL//\//|}"
	done

	g_failed_time=0

	g_current_seed_id=0
	g_current_seed="${SEED_URLS[${g_current_seed_id}]//\//|}"

	if [ -f ${ALLOW_RUN_FLAG}.bak ]; then
		mv ${ALLOW_RUN_FLAG}.bak ${ALLOW_RUN_FLAG}
	fi
}

function CleanRun() {
	if [ -f ${ALLOW_RUN_FLAG} ]; then
		mv ${ALLOW_RUN_FLAG} ${ALLOW_RUN_FLAG}.bak
	fi
	rm -f ${RUNNING_FLAG}
}

function CheckPermission() {
	if [ ! -f ${ALLOW_RUN_FLAG} ]; then
		return 255
	else
		return 0
	fi
}

function CheckLastRound() {
	if [ -f ${RUNNING_FLAG} ]; then
		return 0
	fi
	return 255
}

function StartUp() {
	CheckLastRound
	if [ $? -eq 0 ]; then
		return 1
	else 
		return 2
	fi
}

function GetCurrentTaskOfNew() {
	if [ 0 -eq ${g_current_seed_id} ]; then
		g_failed_time=0
	fi
	g_current_seed="${SEED_URLS[${g_current_seed_id}]//\//|}"
	g_current_task="`ls -l ${FLAG_SCHEDULE_PATH}/${g_current_seed}/ | grep "^-" | grep -v -E "ready|running" | awk '{print $NF}' | head -n 1`"
	if [ x == x"${g_current_task}" ]; then
		((g_failed_time = g_failed_time + 1))
		return 255
	fi
	((g_current_seed_id = (g_current_seed_id + 1) % ${#SEED_URLS[@]}))
	return 0
}

function AppendJobsForTask() {
	mv "${FLAG_SCHEDULE_PATH}/${g_current_seed}/${g_current_task}" "${FLAG_SCHEDULE_PATH}/${g_current_seed}/${g_current_task}".ready
	g_current_depth="`cat "${FLAG_SCHEDULE_PATH}/${g_current_seed}/${g_current_task}".ready`"
}

function RunATask() {
	local round=$1
	local task=$2
	local depth=$3
	local seed=$4
	
	LOG "[${g_current_round}] start task \"${FLAG_SCHEDULE_PATH}${task}\""

	MarkRunningTask ${FLAG_SCHEDULE_PATH}/${seed}/${task}

	CrawlNewsProcessRun "${round}" "${task}" "${depth}" "${seed}"

	UnMarkRunningTask ${FLAG_SCHEDULE_PATH}/${seed}/${task}

	LOG "finish task \"${FLAG_SCHEDULE_PATH}${task}\""

	return 0
}

function MarkRunningTask() {
	 mv $1.ready $1.running
 }

 function UnMarkRunningTask() {
	rm -f $1.running
 }

function Run() {
	local ret=

	g_current_round="`date +\"%Y-%m-%d-%H\"`"

	LOG "[${g_current_round}] scheduled start"

	InitEnv

	StartUp
	ret=$?
	if [ ${ret} -eq 1 ]; then
		LOG "[${g_current_round}] last round schedule processing is running, exit"
		return 0
	fi
	
	InitRun ${g_current_round}

	while ((1))
	do
		CheckPermission
		ret=$?
		if [ ${ret} -ne 0 ]; then
			LOG "[${g_current_round}] crawler missed permission, exit"
			break
		fi

		GetCurrentTaskOfNew
		ret=$?
		if [ ${ret} -ne 0 ]; then
			if [ ${g_failed_time} -eq ${#SEED_URLS[@]} ]; then				
				break
			else
				continue
			fi
		else
			AppendJobsForTask
		fi

		sleep ${SLEEP_TIME}s

		RunATask ${g_current_round} ${g_current_task} ${g_current_depth} ${g_current_seed}
		ret=$?
		if [ ${ret} -ne 0 ]; then
			break
		fi
	done

	CleanRun

	return 0
}

Run
