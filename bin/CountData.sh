#########################################################################
# File Name: CountData.sh
# Author: HouJP
# mail: peng_come_on@126.com
# Created Time: 五 10/31 12:39:55 2014
#########################################################################
# !/bin/bash

PATH_PRE="`pwd`"
PATH_NOW="`dirname $0`"
cd "${PATH_NOW}"
source Utils.sh
source ../conf/crawler.conf
cd "${PATH_PRE}"

function CountData() {
	local total=0
	local num=
	local dirs="`ls -l ${DATA_PATH} | awk '{print $NF}'`"

	for dir in ${dirs[@]}
	do
		if [ -d ${DATA_PATH}${dir} ]; then
			num="`ls -l ${DATA_PATH}/${dir} | wc -l`"
			((total += num))
		fi
	done

	local msg="`LOG "已下载文档总数为 ${total}"`"

	echo "${msg}" >> "${DATA_STATISTICS}"
	echo "${msg}"
}

CountData
