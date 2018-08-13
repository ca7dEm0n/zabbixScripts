#!/bin/bash

###
#
# debug mode list , use 'netastat' command:
# 'TIME_WAIT' 'CLOSE_WAIT' 'FIN_WAIT1' 'ESTABLISHED' 'SYN_RECV' 'LAST_ACK LISTEN'
#
# base mode use 'ss -s' command , faster than debug mode.
#
###


debug(){
    CACHEFILE="/tmp/netstat_an_status.log"
    if [ -e ${CACHEFILE} ]
    then
        TIMEFLM=$(stat -c %Y ${CACHEFILE})
        TIMENOW=$(date +%s)
        if [ $(expr ${TIMENOW} - ${TIMEFLM}) -le 10 ];
        then
            Text=$(cat ${CACHEFILE})
        else
            Text=$(netstat -an | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}')
            echo ${Text} > ${CACHEFILE}
        fi
    else
        Text=$(netstat -an | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}')
        echo ${Text} > ${CACHEFILE}
    fi
    echo ${Text}|grep -oP "(?<=$1 )\d+"
}

base(){
    num=$(ss -s|grep -oP "(?<=$1 )\d+")
    echo ${num:-0}
}

run(){
    local func=$1
    local mode="base"
    DEBUG_MODE_LIST=('TIME_WAIT' 'CLOSE_WAIT' 'FIN_WAIT1' 'ESTABLISHED' 'SYN_RECV' 'LAST_ACK LISTEN')
    for i in ${DEBUG_MODE_LIST[@]}
    do
        if [ "${i}" == "${func}" ]
        then 
            local mode="debug"
            break
        fi
    done
    
    if [ "${mode}" == "base" ]
    then
        request=$(base ${func})
    else
        request=$(debug ${func})
    fi

    if [ ! -n "${func}" ]
    then
        echo 0
    else
        echo ${request}
    fi
}


run $1
