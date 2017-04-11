#!/bin/bash - 
#===============================================================================
#
#          FILE: i-mount.sh
# 
#         USAGE: ./i-mount.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 03/07/2017 17:52:43
#      REVISION:  ---
#===============================================================================

#set -o nounset         # Treat unset variables as an error
#set -x                 # Essentiall turn on debug mode

# note that this is only run on an instance, not within a container.

# check to see if they have entered a path for the XVDG partition
MAIN_MOUNT_PATH=${1:-"empty"}

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

# make use of attached db, xlog, and backup volumes if they exist, otherwise use instance-attached ssd
if [ -b /dev/xvdg ]; then
    mount-volume "/dev/xvdg" ${MAIN_MOUNT_PATH}
else
    if [ -b /dev/nvme0n1 ]; then
        mount-volume "/dev/nvme0n1" "/media/data/"
    else
        mount-volume "/dev/xvdb" ${MAIN_MOUNT_PATH}
    fi
fi

# mount the xlog volume if it is exists
if [ -b /dev/xvdh ]; then
    mount-volume "/dev/xvdh" "/media/data/postgres/xlog"
fi

# mount the backup volume if it is exists
if [ -b /dev/xvdi ]; then
    mount-volume "/dev/xvdi" "/media/data/postgres/backup"
else
    # looks like we need to create the directory if it doesn't exist.  The postgres install and configuration
    # won't do it.
    mkdir -p "/media/data/postgres/backup"
fi

# close up /etc/fstab again
sudo chmod o-w /etc/fstab
