#!/bin/bash -e

sudo useradd celery

sudo cp flower.conf /etc/supervisor/conf.d/flower.conf
sudo cp celery.conf /etc/supervisor/conf.d/celery.conf

echo "Installed customer-specific worker portion"