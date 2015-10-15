#!/bin/bash -evx

. ./postgresenv.sh

#SUPERVISORD
sudo cp ./conf/rsyslogd.conf /etc/supervisor/conf.d/rsyslogd.conf
sudo cp ./conf/postgres.conf /etc/supervisor/conf.d/postgres.conf

