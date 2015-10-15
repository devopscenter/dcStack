#!/bin/bash

echo -e "n\np\n1\n\n\nw" | sudo fdisk /dev/xvdf
sudo mkfs -t ext4 /dev/xvdf
sudo mkdir -p /media/data/jenkins
sudo mount /dev/xvdf /media/data/jenkins

echo -e "n\np\n1\n\n\nw" | sudo fdisk /dev/xvdg
sudo mkfs -t ext4 /dev/xvdg
sudo mkdir -p /media/data/postgres/db
sudo mount /dev/xvdg /media/data/postgres/db

echo -e "n\np\n1\n\n\nw" | sudo fdisk /dev/xvdh
sudo mkfs -t ext4 /dev/xvdh
sudo mkdir /media/data/postgres/xlog
sudo mount /dev/xvdh /media/data/postgres/xlog

MOUNTPATH=/dev/xvdi
DIRECTORY=/media/data/postgres/backup

echo -e "n\np\n1\n\n\nw" | sudo fdisk ${MOUNTPATH}
sudo mkfs -t ext4 ${MOUNTPATH}
sudo mkdir -p ${DIRECTORY}
sudo mount ${MOUNTPATH} ${DIRECTORY}
