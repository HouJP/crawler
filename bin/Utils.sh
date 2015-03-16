#########################################################################
# File Name: Util.sh
# Author: HouJP
# mail: peng_come_on@126.com
# Created Time: 三 10/29 22:22:07 2014
#########################################################################
# !/bin/bash

function LOG() {
	local message="$1"
	local time_stamp="`date +%Y-%m-%d-%T`"
	echo "[${time_stamp}] ${message}"
}
