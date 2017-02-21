#!/bin/bash

# note that this is only run on an instance, not within a container.

# enable us to modify /etc/fstab
sudo chmod o+w /etc/fstab

function mount-volume
{
  MOUNTPATH="$1"
  DIRECTORY="$2"

  # add primary partition if it doesn't exist
  if ! (sudo parted "$MOUNTPATH" print|grep -q ext4); then
    echo -e "n\np\n1\n\n\nw\n" | sudo fdisk ${MOUNTPATH}
  fi

  # create ext4 filesystem if it doesn't exist
  if ! (sudo file -Ls "$MOUNTPATH"|grep -q ext4); then
    if (sudo mount -t ext4|grep -q "$MOUNTPATH"); then
      sudo umount "$MOUNTPATH"
    fi
    echo -e "y\n" | sudo mkfs -t ext4 "$MOUNTPATH"
  fi

  # mount at the target directory
  sudo mkdir -p ${DIRECTORY}
  if ! (mount|grep -q "^${MOUNTPATH}\b[[:blank:]]*\bon\b[[:blank:]]*${DIRECTORY}\b"); then
    sudo mount ${MOUNTPATH} ${DIRECTORY}
  fi

  # add to fstab to mount on boot
  #FSTAB_LINE="${MOUNTPATH}   ${DIRECTORY}     auto    defaults,nobootwait,comment=cloudconfig 0       2"
  FSTAB_LINE="${MOUNTPATH}   ${DIRECTORY}     auto    defaults,comment=cloudconfig 0       2"
  if ! (grep -q "$FSTAB_LINE" /etc/fstab); then
    echo "$FSTAB_LINE" | sudo tee -a /etc/fstab
  fi
}

# make use of attached db volume if it exists, otherwise use instance-attached ssd
if [ -b /dev/xvdg ]
    then
        DB_DEV=/dev/xvdg
    else
        DB_DEV=/dev/xvdb
fi
mount-volume "$DB_DEV" "/media/data/postgres/db"
mount-volume "/dev/xvdh" "/media/data/postgres/xlog"
mount-volume "/dev/xvdi" "/media/data/postgres/backup"

# close up /etc/fstab again
sudo chmod o-w /etc/fstab
