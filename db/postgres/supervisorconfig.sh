#!/bin/bash -evx

PGVERSION=$1
. ./postgresenv.sh $PGVERSION

#SUPERVISORD
sudo cp ./conf/rsyslogd.conf /etc/supervisor/conf.d/rsyslogd.conf
sudo cp ./conf/supervisor-postgres.conf /etc/supervisor/conf.d/postgres.conf
sudo cp ./conf/run_postgres.sh /etc/supervisor/conf.d/run_postgres.sh

