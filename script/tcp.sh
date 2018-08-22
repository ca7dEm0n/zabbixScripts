#!/bin/bash

###
#
# debug mode list , use 'ss -ant' command.
#
# base mode use 'ss -s' command , faster than debug mode.
#
###

cache(){
    local COMMAND=$1
    FILENAME=$(echo ${COMMAND///}|awk -F " " '{print $1$2}')
    CACHEFILE="/tmp/${FILENAME}"
    if [ -e ${CACHEFILE} ]
    then
        TIMEFLM=$(stat -c %Y ${CACHEFILE})
        TIMENOW=$(date +%s)
        if [ $(expr ${TIMENOW} - ${TIMEFLM}) -le 5 ];
        then
            TEXT=$(cat ${CACHEFILE})
        else
            TEXT=$(echo ${COMMAND}|sh)
            echo ${TEXT} > ${CACHEFILE}
        fi
    else
        TEXT=$(echo ${COMMAND}|sh)
        echo ${TEXT} > ${CACHEFILE}
    fi
    echo ${TEXT}
}

debug(){
    local VALUE=$1
    EXE=$(cache "/usr/sbin/ss -ant | grep -v State |awk '{print \$1}' |sort |uniq -c")
    RESPONSE=$(echo ${EXE}|grep -oP "\d+ (?=${VALUE})")
    echo ${RESPONSE:-0}
}

base(){
    local VALUE=$1
    EXE=$(cache "/usr/sbin/ss -s")
    RESPONSE=$(echo ${EXE}|grep -oP "(?<=$1 )\d+")
    echo ${RESPONSE:-0}
}

run(){
    local FUNC=$1
    local MODE="debug"
    BASE_MODE_LIST=('estab' 'closed' 'orphaned' 'synrecv' 'timewait')
    for i in ${BASE_MODE_LIST[@]}
    do
        if [ "${i}" == "${FUNC}" ]
        then
            local MODE="base"
            break
        fi
    done

    if [ "${MODE}" == "base" ]
    then
        RESPONSE=$(base ${FUNC})
    else
        RESPONSE=$(debug ${FUNC})
    fi

    if [ ! -n "${FUNC}" ]
    then
        echo 0
    else
        echo ${RESPONSE}
    fi
}

run $1
