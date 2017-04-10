#!/bin/bash -e

cp app-conf/supervisor-djangorq-worker.conf /installs/supervisor-djangorq-worker.conf
cp app-conf/supervisor-djangorq-worker.conf /etc/supervisor/conf.d/djangorq-worker.conf
