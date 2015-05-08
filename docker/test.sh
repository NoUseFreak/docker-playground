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

NAME=docker-test
DESC="Container"
PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/bin/docker

MYSQL_IMAGE=percona
REDIS_IMAGE=redis
SOLR_IMAGE=solr
RABBITMQ_IMAGE=rabbitmq
PHPFPM_IMAGE=php56
NGINX_IMAGE=nginx

# Source function library
. /lib/lsb/init-functions

CIDREDISFILE=/var/run/${NAME}-redis.cid
CIDSOLRFILE=/var/run/${NAME}-solr.cid
CIDRABBITMQFILE=/var/run/${NAME}-rabbitmq.cid
CIDPHPFPMFILE=/var/run/${NAME}-phpfpm.cid
CIDNGINXFILE=/var/run/${NAME}-nginx.cid
CIDMYSQLFILE=/var/run/${NAME}-mysql.cid

test -x ${DAEMON} || exit 0

# Ensure we have a PATH
export PATH="${PATH:+$PATH:}/usr/sbin:/usr/bin:/sbin:/bin"


DATADIR_LOCAL=/vagrant
DATADIR_DOCKER=/var/app
EXPOSE_PORT=80
MYSQL_EXPOSE_PORT=3306
MYSQL_ROOT_PASSWORD=root
SOLR_EXPOSE_PORT=8983

mkdir -p /var/docker/data/${NAME}/mysql
mkdir -p /var/docker/data/${NAME}/solr

function is_running {

    if [ -f "${CIDMYSQLFILE}" ]; then
        MYSQLCID=`cat ${CIDMYSQLFILE}`
        if [ `docker ps --no-trunc | awk '{ print $1 }' | grep ${MYSQLCID} | wc -l` != "0" ]; then
            return 0
        fi
    fi

    if [ -f "${CIDREDISFILE}" ]; then
        REDISCID=`cat ${CIDREDISFILE}`
        if [ `docker ps --no-trunc | awk '{ print $1 }' | grep ${REDISCID} | wc -l` != "0" ]; then
            return 0
        fi
    fi
    
    if [ -f "${CIDSOLRFILE}" ]; then
        SOLRCID=`cat ${CIDSOLRFILE}`
        if [ `docker ps --no-trunc | awk '{ print $1 }' | grep ${SOLRCID} | wc -l` != "0" ]; then
            return 0
        fi
    fi

    if [ -f "${CIDRABBITMQFILE}" ]; then
        RABBITMQCID=`cat ${CIDRABBITMQFILE}`
        if [ `docker ps --no-trunc | awk '{ print $1 }' | grep ${RABBITMQCID} | wc -l` != "0" ]; then
            return 0
        fi
    fi

    if [ -f "${CIDPHPFPMFILE}" ]; then
        PHPFPMCID=`cat ${CIDPHPFPMFILE}`
        if [ `docker ps --no-trunc | awk '{ print $1 }' | grep ${PHPFPMCID} | wc -l` != "0" ]; then
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

    SOLRCID=`docker run -d -p ${SOLR_EXPOSE_PORT}:8983 -v /var/docker/data/${NAME}/solr:/var/solr ${NAME}_${SOLR_IMAGE}`
    echo ${SOLRCID} > ${CIDSOLRFILE}

    MYSQLCID=`docker run -d -v /var/docker/data/${NAME}/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} -p ${MYSQL_EXPOSE_PORT}:3306 ${NAME}_${MYSQL_IMAGE}`
    echo ${MYSQLCID} > ${CIDMYSQLFILE}

    REDISCID=`docker run -d ${NAME}_${REDIS_IMAGE}`
    echo ${REDISCID} > ${CIDREDISFILE}

    RABBITMQCID=`docker run -d ${NAME}_${RABBITMQ_IMAGE}`
    echo ${RABBITMQCID} > ${CIDRABBITMQFILE}

    PHPFPMCID=`docker run -v ${DATADIR_LOCAL}:${DATADIR_DOCKER}:ro -d --link ${MYSQLCID}:mysql --link ${SOLRCID}:solr --link ${SOLRCID}:solr --link ${RABBITMQCID}:rabbitmq --link ${REDISCID}:redis ${NAME}_${PHPFPM_IMAGE}`
    echo ${PHPFPMCID} > ${CIDPHPFPMFILE}

    NGINXCID=`docker run -v ${DATADIR_LOCAL}:${DATADIR_DOCKER}:ro  -d -p ${EXPOSE_PORT}:80 --link ${PHPFPMCID}:php ${NAME}_${NGINX_IMAGE}`
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

    CIDMYSQL=`cat ${CIDMYSQLFILE}`
    docker rm -f ${CIDMYSQL} >> /dev/null
    
    CIDREDIS=`cat ${CIDREDISFILE}`
    docker rm -f ${CIDREDIS} >> /dev/null
    
    CIDSOLR=`cat ${CIDSOLRFILE}`
    docker rm -f ${CIDSOLR} >> /dev/null
    
    CIDRABBITMQ=`cat ${CIDRABBITMQFILE}`
    docker rm -f ${CIDRABBITMQ} >> /dev/null

    CIDPHPFPM=`cat ${CIDPHPFPMFILE}`
    docker rm -f ${CIDPHPFPM} >> /dev/null

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

function update_docker_containers {
    cd /vagrant/docker/nginx && docker build --rm -t ${NAME}_${NGINX_IMAGE} .
    cd /vagrant/docker/redis && docker build --rm -t ${NAME}_${REDIS_IMAGE} .
    cd /vagrant/docker/solr && docker build --rm -t ${NAME}_${SOLR_IMAGE} .
    cd /vagrant/docker/rabbitmq && docker build --rm -t ${NAME}_${RABBITMQ_IMAGE} .
    cd /vagrant/docker/php56 && docker build --rm -t ${NAME}_${PHPFPM_IMAGE} .
    cd /vagrant/docker/percona56 && docker build --rm -t ${NAME}_${MYSQL_IMAGE} .
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
    update)
        update_docker_containers
        ;;
    *)
        log_success_msg "Usage: $0 {start|stop|restart|force-reload|update}"
        exit 1
        ;;
esac

exit 0
