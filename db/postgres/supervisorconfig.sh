#!/bin/bash -evx

. ./postgresenv.sh

#SUPERVISORD
cp ./conf/rsyslogd.conf /etc/supervisor/conf.d/rsyslogd.conf
cp ./conf/postgres.conf /etc/supervisor/conf.d/postgres.conf

