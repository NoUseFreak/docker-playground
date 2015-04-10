#!/usr/bin/env bash

### BEGIN INIT INFO
# Provides:          docker-test
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start docker-test
# Description:       This script provides a server-side cache
#                    to be run in front of a httpd and should
#                    listen on port 80 on a properly configured
#                    system
### END INIT INFO

# Source function library
. /lib/lsb/init-functions


NAME=docker-test
DESC="Container"
PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/bin/docker

CIDPHPFILE=/var/run/${NAME}-php.cid
CIDNGINXFILE=/var/run/${NAME}-nginx.cid

test -x $DAEMON || exit 0

# Ensure we have a PATH
export PATH="${PATH:+$PATH:}/usr/sbin:/usr/bin:/sbin:/bin"


DATADIR_LOCAL=/vagrant/data/test
DATADIR_DOCKER=/var/www2
EXPOSE_PORT=80

CPATH=/tmp/test

mkdir -p ${CPATH}


function is_running {

    if [ -f "${CIDPHPFILE}" ]; then
        PHPCID=`cat ${CIDPHPFILE}`
        if [ `docker ps --no-trunc | awk '{ print $1 }' | grep ${PHPCID} | wc -l` != "0" ]; then
            return 0
        fi
    fi

    if [ -f "${CIDNGINXFILE}" ]; then
        NGINXCID=`cat ${CIDNGINXFILE}`
        if [ `docker ps --no-trunc | awk '{ print $1 }' | grep ${NGINXCID} | wc -l` != "0" ]; then
            return 0
        fi
    fi

    return 1
}

function start_docker_instance {
    log_daemon_msg "Starting $DESC" "$NAME"

    if is_running; then
        log_end_msg 1
        echo "Already running"
        exit 1
    fi

    PHPCID=`docker run -v ${DATADIR_LOCAL}:${DATADIR_DOCKER}:ro -d php56`
    echo ${PHPCID} > ${CIDPHPFILE}

    NGINXCID=`docker run -v ${DATADIR_LOCAL}:${DATADIR_DOCKER}:ro  -d -p ${EXPOSE_PORT}:80 --link ${PHPCID}:php nginx_test`
    echo ${NGINXCID} > ${CIDNGINXFILE}

    log_end_msg 0
}


function stop_docker_instance {

    log_daemon_msg "Stopping $DESC" "$NAME"

    if ! is_running; then
        log_end_msg 1
        echo "Not running"
        exit 1
    fi

    CIDPHP=`cat ${CIDPHPFILE}`
    docker rm -f ${CIDPHP} >> /dev/null

    CIDNGINX=`cat ${CIDNGINXFILE}`
    docker rm -f ${CIDNGINX} >> /dev/null

    if is_running; then
        log_end_msg 1
        echo "Failed to stop"
        exit 1
    fi

    log_end_msg 0
}

function status_docker_instance {

    if is_running; then
        log_daemon_msg "$DESC" "$NAME" "is running"
        exit 0
    else
        log_daemon_msg "$DESC" "$NAME" "is not running"
        exit 1
    fi
}

case "$1" in
    start)
        start_docker_instance
        ;;
    stop)
        stop_docker_instance
        ;;
    status)
        status_docker_instance
        ;;
    restart|force-reload)
        $0 stop
        $0 start
        ;;
    *)
        log_success_msg "Usage: $0 {start|stop|restart|force-reload}"
        exit 1
        ;;
esac

exit 0
