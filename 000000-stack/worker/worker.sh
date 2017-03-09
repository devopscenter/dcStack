#!/bin/bash -e

sudo mkdir -p /data/deploy /data/media /data/scratch

cp supervisor-djangorq-worker.conf /installs/supervisor-djangorq-worker.conf
cp supervisor-djangorq-worker.conf /etc/supervisor/conf.d/djangorq-worker.conf
