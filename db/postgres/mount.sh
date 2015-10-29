#!/bin/bash

MOUNTPATH=/dev/xvdb
DIRECTORY=/media/data/postgres/db

echo -e "n\np\n1\n\n\nw" | sudo fdisk ${MOUNTPATH}
sudo mkfs -t ext4 ${MOUNTPATH}
sudo mkdir -p ${DIRECTORY}
sudo mount ${MOUNTPATH} ${DIRECTORY}


MOUNTPATH=/dev/xvdh
DIRECTORY=/media/data/postgres/xlog

echo -e "n\np\n1\n\n\nw" | sudo fdisk ${MOUNTPATH}
sudo mkfs -t ext4 ${MOUNTPATH}
sudo mkdir -p ${DIRECTORY}
sudo mount ${MOUNTPATH} ${DIRECTORY}


MOUNTPATH=/dev/xvdi
DIRECTORY=/media/data/postgres/backup

echo -e "n\np\n1\n\n\nw" | sudo fdisk ${MOUNTPATH}
sudo mkfs -t ext4 ${MOUNTPATH}
sudo mkdir -p ${DIRECTORY}
sudo mount ${MOUNTPATH} ${DIRECTORY}
