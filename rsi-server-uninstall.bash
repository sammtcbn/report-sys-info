#!/bin/bash

SERVICE_NAME=rsi-server.service

function failed()
{
    echo "$*" >&2
    exit 1
}

if [ -e /etc/systemd/system/${SERVICE_NAME} ]; then
    systemctl stop ${SERVICE_NAME} || failed "Fail to stop service"
    systemctl disable ${SERVICE_NAME} || failed "Fail to disable service"
    rm -f --preserve-root /etc/systemd/system/${SERVICE_NAME} || failed "Fail to delete service file"
fi

rm -f --preserve-root /usr/local/bin/rsi-server.bash || failed "Fail to delete rsi-server"
rm -f --preserve-root /usr/local/bin/rsi-server-uninstall.bash || failed "Fail to delete rsi-server"

echo "uninstall done"
