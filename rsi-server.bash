#!/bin/bash

conf=/usr/local/etc/rsi-server.conf

mqtt_server=127.0.0.1
mqtt_topic=rsi/sysinfo

function failed()
{
    echo "$*" >&2
    exit 1
}

function conf_load ()
{
    if [ -f ${conf} ]; then
        mqtt_server=$(cat ${conf} | grep mqtt_server= | awk 'BEGIN {FS="="}; {print $2}')
    fi
    #echo mqtt_server = ${mqtt_server}
}

conf_load

mosquitto_sub -h ${mqtt_server} -t ${mqtt_topic} -v | while read -r topic payload
do
    echo ${payload}
    logger rsi ${payload}
done
