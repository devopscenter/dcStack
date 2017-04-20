#!/bin/bash -e

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific worker for 9900af"

cp app-conf/supervisor-djangorq-worker.conf /installs/supervisor-djangorq-worker.conf
cp app-conf/supervisor-djangorq-worker.conf /etc/supervisor/conf.d/djangorq-worker.conf

dcEndLog "install of app-specific worker for 9900af"
