#!/bin/bash
group=("logstash")
kafkaNode="xx:9092"

sf(){
    for i in ${group[@]}
    do
        /usr/bin/kafka-consumer-groups --new-consumer --describe --group ${i} \
                                       --bootstrap-server ${kafkaNode} > /tmp/${i}.log 2> /dev/null 
    done
}

co(){
    local file=$1
    if [ -e /tmp/${file}.log ]
    then
        TIMEFLM=$(stat -c %Y /tmp/${file}.log)
        TIMENOW=$(date +%s)
        if [ $(expr ${TIMENOW} - ${TIMEFLM}) -le 60 ]
        then
            cat /tmp/${file}.log |awk '{if (NR>2) {SUM+=$3}}END{print SUM}'
        else
            echo 0
        fi
    fi
}


lo(){
    local file=$1
    if [ -e /tmp/${file}.log ]
    then
        TIMEFLM=$(stat -c %Y /tmp/${file}.log)
        TIMENOW=$(date +%s)
        if [ $(expr ${TIMENOW} - ${TIMEFLM}) -le 60 ]
        then
            cat /tmp/${file}.log |awk '{if (NR>2) {SUM+=$4}}END{print SUM}'
        else
            echo 0
        fi
    fi
}


lg(){
    local file=$1
    if [ -e /tmp/${file}.log ]
    then
        TIMEFLM=$(stat -c %Y /tmp/${file}.log)
        TIMENOW=$(date +%s)
        if [ $(expr ${TIMENOW} - ${TIMEFLM}) -le 60 ]
        then
            cat /tmp/${file}.log |awk '{if (NR>2) {SUM+=$5}}END{print SUM}'
        else
            echo 0
        fi
    fi
}

case $1 in
    CURRENT-OFFSET)
        co $2 ;;
    LOG-END-OFFSET)
        lo $2 ;;
               LAG)
        lg $2 ;;
              SAVE)
        sf  ;;
               *)
        echo "Usage: sh $0 [CURRENT-OFFSET | LOG-END-OFFSET | LAG | SAVE]  <GROUP>"
esac
