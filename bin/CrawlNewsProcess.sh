#########################################################################
# File Name: CrawlNewsProcess.sh
# Author: HouJP
# mail: peng_come_on@126.com
# Created Time: 四 10/30 08:33:12 2014
#########################################################################
# !/bin/bash

PATH_PRE="`pwd`"
PATH_NOW="`dirname $0`"
cd ${PATH_NOW}

source Utils.sh
source ../conf/crawler.conf

cd ${PATH_PRE}

set -o pipefail
set -x

function InitProcessEnv() {
	local round=$1
	local task=$2
	local seed=$3

	mkdir -p ${FLAG_SCHEDULE_BAK_PATH}/${seed}/
	touch ${FLAG_SCHEDULE_BAK_PATH}/${seed}/${task}.running

	mkdir -p "${DATA_PATH}/${round}/${seed}"
}

function MarkSuccessfulTask() {
	local round=$1
	local task=$2
	local seed=$3

	#mkdir -p ${EXTRACTER_FLAG_SCHEDULE_PATH}/${round}
	#touch ${EXTRACTER_FLAG_SCHEDULE_PATH}/${round}/${task}
	rm -f ${FLAG_SCHEDULE_BAK_PATH}/${seed}/${task}.running
}

function MarkRepeatedTask() {
	rm -f ${FLAG_SCHEDULE_BAK_PATH}/${seed}/${task}.running
}

function MarkFailedTask() {
	local round=$1
	local task=$2
	local seed=$3

	mv ${FLAG_SCHEDULE_BAK_PATH}/${seed}/${task}.running ${FLAG_SCHEDULE_BAK_PATH}/${seed}/${task}.failed
}

function ExecuteCurrentTask() {
	local round=$1
	local task=$2
	local depth=$3
	local seek=$4
	local ret=

	CheckRepetition ${round} ${task} ${task}
	ret=$?
	if [ 0 -ne ${ret} ]; then
		return 1
	fi

	sleep ${SLEEP_TIME}s

	DownloadURL ${round} ${task} ${seed}
	ret=$?
	if [ 0 -ne ${ret} ]; then
		return 255
	fi

	if [ ${DEGREE_OF_DEPTH} -gt ${depth} ]; then
		ExtractURL ${round} ${task} ${depth} ${seed}
		ret=$?
		if [ 0 -ne ${ret} ]; then
			return 255
		fi
	fi

	AddURL ${round} ${task} ${task} ${seed}
}

function DownloadURL() {
	local round=$1
	local task=$2
	local seed=$3

	python "${BIN_DOWNLOADPAGE}" "${task//|//}" > "${DATA_PATH}/${round}/${seed}/${task}"
	ret=$?
	if [ 0 -ne ${ret} ]; then
		rm -f "${DATA_PATH}/${round}/${seed}/${task}"
		return 255
	else
		return 0
	fi
}

function ExtractURL() {
	local round=$1
	local task=$2
	local depth=$3
	local seed=$4
	local links=""

	local links="`python "${BIN_EXTRACTURL}" "${DATA_PATH}/${round}/${seed}/${task}" "${seed//|//}"`"
	local ret=$?
	if [ 0 -ne ${ret} ]; then
		return 255
	fi

	echo "${links}" | while read link
	do
		if [ x != x"${link}" ]; then
			CheckRepetition "$round" "$task" "${link////|}"
			ret=$?
			if [ 0 -eq ${ret} ]; then
				AppendTask "${round}" "${task}" "${link////|}" ${depth} ${seed}
			fi
		fi
	done

	return 0
}

function CheckRepetition() {
	local round=$1
	local task=$2
	local link=$3
	local downloaded_sub_path=""
	local downloaded_sub_name=""
	local i=

	local sub_link=(${link//|/ })
	local sub_link_len=${#sub_link[@]}
	for((i = 1; i < ${sub_link_len} - 1; ++i))
	do
		downloaded_sub_path=${downloaded_sub_path}/${sub_link[i]}/
	done
	downloaded_sub_name=${sub_link[${sub_link_len} - 1]}

	if [ ! -d "${FLAG_DOWNLOADED_PATH}/${downloaded_sub_path}/" ]; then
		mkdir -p "${FLAG_DOWNLOADED_PATH}/${downloaded_sub_path}/"
	fi
	if [ ! -f "${FLAG_DOWNLOADED_PATH}/${downloaded_sub_path}/urls" ]; then
		touch "${FLAG_DOWNLOADED_PATH}/${downloaded_sub_path}/urls"
	fi

	local line=
	local urls_line_num="`cat ${FLAG_DOWNLOADED_PATH}/${downloaded_sub_path}/urls | wc -l`"
	for ((i = 1; i <= ${urls_line_num}; ++i))
	do
		line="`sed -n "${i}p" ${FLAG_DOWNLOADED_PATH}/${downloaded_sub_path}/urls`"
		if [ ${line} == ${downloaded_sub_name} ]; then
			return 1
		fi
	done

	return 0
}

function AddURL() {
	local round=$1
	local task=$2
	local link=$3
	local seed=$4
	local downloaded_sub_path=""
	local downloaded_sub_name=""
	local i=

	local sub_link=(${link//|/ })
	local sub_link_len=${#sub_link[@]}
	for((i = 1; i < ${sub_link_len} - 1; ++i))
	do
		downloaded_sub_path=${downloaded_sub_path}/${sub_link[i]}/
	done
	downloaded_sub_name=${sub_link[${sub_link_len} - 1]}

	if [ ! -d "${FLAG_DOWNLOADED_PATH}/${downloaded_sub_path}/" ]; then
		mkdir -p "${FLAG_DOWNLOADED_PATH}/${downloaded_sub_path}/"
	fi
	if [ ! -f "${FLAG_DOWNLOADED_PATH}/${downloaded_sub_path}/urls" ]; then
		touch "${FLAG_DOWNLOADED_PATH}/${downloaded_sub_path}/urls"
	fi

	echo "${downloaded_sub_name}" >> ${FLAG_DOWNLOADED_PATH}/${downloaded_sub_path}/urls

	return 0
}
function AppendTask() {
	local round=$1
	local task=$2
	local link=$3
	local depth=$4
	local seed=$5

	touch "${FLAG_SCHEDULE_PATH}/${seed}/${link}"
	((depth = depth + 1))
	echo "${depth}" > "${FLAG_SCHEDULE_PATH}/${seed}/${link}"
}

function ClearProcessEnv() {
	local round=$1
	local task=$2
}

function CrawlNewsProcessRun() {
	if [ $# -ne 4 ]; then
		LOG "<$#>invalid parameter count with function CrawlNewsProcessRun"
		return 255
	fi

	local round=$1
	local task=$2
	local depth=$3
	local seed=$4
	local ret=

	InitProcessEnv ${round} ${task} ${seed}

	ExecuteCurrentTask ${round} ${task} ${depth} ${seed}
	ret=$?
	if [ 0 -eq ${ret} ]; then
		MarkSuccessfulTask ${round} ${task} ${seed}
	elif [ 1 -eq ${ret} ]; then
		MarkRepeatedTask ${round} ${task} ${seed}
	else
		MarkFailedTask ${round} ${task} ${seed}
	fi

	ClearProcessEnv ${round} ${task}

	return 0
}

# CrawlNewsProcessRun $1 $2 $3
