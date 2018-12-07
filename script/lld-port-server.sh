#!/bin/bash
DATAFILE="/tmp/PortServerLLD"
LASTDATAFILE=${DATAFILE}".last"

Diff() {
    OLDIFS=$IFS
    IFS=$'\n'
    text=""
    [ ! -f ${LASTDATAFILE} ] && touch ${LASTDATAFILE}
    for i in `diff -yBb ${DATAFILE} ${LASTDATAFILE}`
    do
        a=$(echo ${i}|awk '{print $1}')
        b=$(echo ${i}|awk '{print $2}')
        if [ "${b}" == "<" ]
        then
            t="[ADD] ${a}\n"
            text=${text}${t}
        elif [ "${b}" == ">" ]
        then
            t="[CLOSE] ${a}\n"
            text=${text}${t}
        elif [ "${b}" == "|" ]
        then
            t="[CHANGE] ${a}\n"
            text=${text}${t}
        fi
    done
    IFS=$OLDIFS
    if [ ! -z "${text}" ]
    then
        printf "${text}"
    fi
    \cp -ap ${DATAFILE} ${LASTDATAFILE}
    exit 0
}

Down() {
    [ ! -f ${DATAFILE} ] && touch ${DATAFILE}
    ss -pltun  |grep -oP "(?<=:)(\d+ ).*"| awk '{if ($3=="")print $1 ":null";else print $1":"$3}'|sed 's/users:(("//g'|sed 's/",.*//g'| sort|uniq > ${DATAFILE}
    chown zabbix. ${DATAFILE}
    chmod 640 ${DATAFILE}
}

Get() {
    if [ -e ${DATAFILE} ]
    then
        TIMEFLM=$(stat -c %Y ${DATAFILE})
        TIMENOW=$(date +%s)
        if [ $(expr ${TIMENOW} - ${TIMEFLM}) -le 120 ];
        then 
            data=($(cat ${DATAFILE}))
            length=${#data[@]}
            printf "{\n"
            printf  '\t'"\"data\":["
            for ((i=0;i<$length;i++))
            do
                item=${data[$i]}
                value=(${item//\:/ })
                printf '\n\t\t{'
                printf "\"{#TCP_PORT}\":\"${value[0]}\","
                printf "\"{#TCP_NAME}\":\"${value[1]}\"}"
                if [ $i -lt $[$length-1] ];then
                    printf ','
                fi
            done
            printf  "\n\t]\n"
            printf "}\n"
        fi 
    fi
    exit 0 
}

$1