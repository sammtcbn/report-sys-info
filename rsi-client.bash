#!/bin/bash
conf=/usr/local/etc/rsi-client.conf

poll_interval=3600

inet=eth0
ip=
hostname=

mqtt_server=
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

    target_msg=${hostname},${ip}
    #echo ${target_msg}
}

function mqtt_pub ()
{
    payload=$1
    mosquitto_pub -h ${mqtt_server} -t ${mqtt_topic} -d -m ${payload} > /dev/null 2>&1
}

conf_load

while true; do
    collect_info
    mqtt_pub ${target_msg}
    sleep ${poll_interval}
done

