#!/bin/bash -e

sudo useradd celery

# Required directories for f1
sudo mkdir -p /data/deploy /data/media /data/scratch 
sudo chown celery:celery /data/scratch 


