#!/bin/bash

SERVICE_NAME=rsi-client.service

function failed()
{
    echo "$*" >&2
    exit 1
}

function cmd_exists ()
{
    if ! type $1> /dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

function env_check_cmd ()
{
    local cmd=$1
    if cmd_exists $cmd ; then
        echo "$cmd found"
    else
        failed "$cmd doesn't exist"
    fi
}

function env_check ()
{
    env_check_cmd ip
    env_check_cmd hostname
    env_check_cmd awk
    env_check_cmd mosquitto_pub
}

env_check

cp -f rsi-client.bash /usr/local/bin || failed "install fail"

cp -f rsi-client.service /etc/systemd/system || failed "install fail"
systemctl daemon-reload || failed "install fail"
chmod 664 /etc/systemd/system/${SERVICE_NAME} || failed "install fail"
chown root.root /etc/systemd/system/${SERVICE_NAME} || failed "install fail"
systemctl enable ${SERVICE_NAME} || failed "install fail"
systemctl start ${SERVICE_NAME} || failed "install fail"

echo "install done"
