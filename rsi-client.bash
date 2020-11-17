#!/bin/bash
conf=/usr/local/etc/rsi-client.conf

poll_interval=3600

inet=eth0
ip=
hostname=
freespace=

mqtt_server=127.0.0.1
mqtt_topic=rsi/sysinfo

target_msg=

function failed()
{
    echo "$*" >&2
    exit 1
}

function get_ip ()
{
    if [ -z $1 ]; then
        return
    fi
    interfacetmp=$1

    # check if interface exist
    ip addr show ${interfacetmp} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        return
    fi

    local iptmp=$(ip addr show ${interfacetmp} | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
    echo ${iptmp}
}

function get_hostname ()
{
    local hostname=$(hostname)
    echo ${hostname}
}

function get_free_space ()
{
    local free_space
    free_space=$(df -h --output=avail / | tail -n1 | xargs)
    echo ${free_space}
}

function conf_load ()
{
    if [ -f ${conf} ]; then
        inet=$(cat ${conf} | grep inet= | awk 'BEGIN {FS="="}; {print $2}')
        mqtt_server=$(cat ${conf} | grep mqtt_server= | awk 'BEGIN {FS="="}; {print $2}')
        poll_interval=$(cat ${conf} | grep poll_interval= | awk 'BEGIN {FS="="}; {print $2}')
    fi
    #echo inet = ${inet}
    #echo mqtt_server = ${mqtt_server}
    #echo poll_interval = ${poll_interval}
}

function collect_info ()
{
    ip=$(get_ip ${inet})
    #echo ip = ${ip}

    hostname=$(get_hostname)
    #echo hostname = ${hostname}

    free_space=$(get_free_space)
    #echo free_space = ${free_space}

    target_msg="${hostname},${ip},${free_space} free space"
    #echo ${target_msg}
}

function mqtt_pub ()
{
    payload=$@
    #echo ${payload}
    mosquitto_pub -h ${mqtt_server} -t ${mqtt_topic} -d -m "${payload}" > /dev/null 2>&1
}

while true; do
    conf_load
    collect_info
    mqtt_pub ${target_msg}
    sleep ${poll_interval}
done

logger rsi-client.bash exit
