#!/bin/bash
ES_HOST=""
ES_PORT="9200"
INDEX="elastalert_status"

get_status(){
    local rule=${1//_/ }
    query=$(cat << EOF
{
  "query" : {
    "bool": {
      "must": [
        {"match" : {"rule_name": "${rule}"}},
        {"range" : {"@timestamp":{"gte":"now-15m"}}}
      ]
    }
   }
} 
EOF
)
    get_data=$(curl -s -XPOST  "${ES_HOST}:${ES_PORT}/${INDEX}/_search?size=1" \
        -H 'Content-Type: application/json' -d "${query}")
    result=$(echo $get_data |grep -oP "(?<=rule_name\"\:)\"[^\"]*\"")
    echo "${rule}" |grep -qw "${result//\"/}" && echo 0 || echo 1
    exit 0
}

get_rules(){
    get_scroll=$(curl -s -XPOST "${ES_HOST}:${ES_PORT}/${INDEX}/_search?size=1000&_source=rule_name" \
        -H 'Content-Type: application/json' -d '
{
    "query" : {
        "match_all" : {}
    }
}')
    result=$(echo $get_scroll |grep -oP "(?<=rule_name\"\:)\"[^\"]*\""|sort|uniq|sed 's/"//g'|sed 's/ /_/g'|tr '\n' '|')  
    data=(${result//|/ })
    length=${#data[@]}
    printf "{\n"
    printf  '\t'"\"data\":["
    for ((i=0;i<$length;i++))
    do
        item=${data[$i]}
        printf '\n\t\t{'
        printf "\"{#RULE_NAME}\":\"${item}\"}"
        if [ $i -lt $[$length-1] ];then
            printf ','
        fi
    done
    printf  "\n\t]\n"
    printf "}\n"
    exit 0 
}
$1 $2