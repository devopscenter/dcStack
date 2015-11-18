#!/bin/bash

# note that this is only run on an instance, not within a container.

# make use of attached db volume if it exists, otherwise use instance-attached ssd.

if [ -b /dev/xvdg ]
    then
        MOUNTPATH=/dev/xvdg
    else
        MOUNTPATH=/dev/xvdb
fi
DIRECTORY=/media/data/postgres/db

echo -e "n\np\n1\n\n\nw" | sudo fdisk ${MOUNTPATH}
sudo mkfs -t ext4 ${MOUNTPATH}
sudo mkdir -p ${DIRECTORY}
sudo mount ${MOUNTPATH} ${DIRECTORY}
sudo echo ${MOUNTPATH} " " ${DIRECTORY} "    auto    defaults,nobootwait,comment=cloudconfig 0       2" >> /etc/fstab


MOUNTPATH=/dev/xvdh
DIRECTORY=/media/data/postgres/xlog

echo -e "n\np\n1\n\n\nw" | sudo fdisk ${MOUNTPATH}
sudo mkfs -t ext4 ${MOUNTPATH}
sudo mkdir -p ${DIRECTORY}
sudo mount ${MOUNTPATH} ${DIRECTORY}
sudo echo ${MOUNTPATH} " " ${DIRECTORY} "    auto    defaults,nobootwait,comment=cloudconfig 0       2" >> /etc/fstab



MOUNTPATH=/dev/xvdi
DIRECTORY=/media/data/postgres/backup

echo -e "n\np\n1\n\n\nw" | sudo fdisk ${MOUNTPATH}
sudo mkfs -t ext4 ${MOUNTPATH}
sudo mkdir -p ${DIRECTORY}
sudo mount ${MOUNTPATH} ${DIRECTORY}
sudo echo ${MOUNTPATH} " " ${DIRECTORY} "    auto    defaults,nobootwait,comment=cloudconfig 0       2" >> /etc/fstab

