#!/usr/bin/env bash
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
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 03/07/2017 17:52:43
#      REVISION:  ---
#
# Copyright 2014-2017 devops.center llc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#===============================================================================

#set -o nounset     # Treat unset variables as an error
#set -o errexit      # exit immediately if command exits with a non-zero status
set -x             # essentially debug mode

# note that this is only run on an instance, not within a container.

# check to see if they have entered a path for the XVDG partition
MAIN_MOUNT_PATH=${1:-"empty"}
ENCRYPT_FS=${2:-"no"}

# enable us to modify /etc/fstab
sudo chmod o+w /etc/fstab

#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  mount-volume
#   DESCRIPTION:  mounts a volume without encryption
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
mount-volume()
{
    MOUNTPATH="$1"
    DIRECTORY="$2"
    ENCRYPT_FS=$3

    if [[ ${ENCRYPT_FS} != "no" ]]; then
        mount-volume-encrypted ${MOUNTPATH} ${DIRECTORY}
    else
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
    fi
}


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  mount-volume-encrypted
#   DESCRIPTION:  mounts a volume with encryption using dm-crypt LUKS 
#    PARAMETERS:  
#       RETURNS:  
#-------------------------------------------------------------------------------
mount-volume-encrypted()
{
    MOUNTPATH="$1"
    DIRECTORY="$2"

    # create it like normal
    # add primary partition if it doesn't exist
    if ! (sudo parted "$MOUNTPATH" print|grep -q ext4); then
        echo -e "n\np\n1\n\n\nw\n" | sudo fdisk ${MOUNTPATH}
    fi

    # make sure it is unmounted
    if (sudo mount -t ext4|grep -q "$MOUNTPATH"); then
        sudo umount "$MOUNTPATH"
    fi

    # setup encryption on the partion
    echo -n "dcPassphrase" | sudo cryptsetup --cipher aes-xts-plain --key-size 512 --hash sha512 -v luksFormat ${MOUNTPATH}

    # mount the encrypted partion needs to go through a mapper  to 
    # provide the correct file system interface.  Think of this as a label
    ENCRYPT_LABEL="dcencryptedvol-"$(basename ${MOUNTPATH})
    echo -n "dcPassphrase" | sudo cryptsetup luksOpen ${MOUNTPATH} ${ENCRYPT_LABEL}

    # create a 4k key with random bits in it
    if [[ ! -d /etc/dcLuks ]]; then
        sudo mkdir -p /etc/dcLuks
    fi
    KEYNAME="luks-key-"$(basename ${MOUNTPATH})
    sudo dd if=/dev/urandom of=/etc/dcLuks/${KEYNAME} bs=512 count=8

    # make sure the permission are correct on that key file
    sudo chmod 600 /etc/dcLuks/${KEYNAME}

    # and now add that key
    echo -n "dcPassphrase" | sudo cryptsetup -v luksAddKey ${MOUNTPATH} /etc/dcLuks/${KEYNAME}

    # create the ext4 filesystem on it
    echo -e "y\n" | sudo mkfs -t ext4 -L LuksPartition /dev/mapper/${ENCRYPT_LABEL}

    # and now create the directory
    sudo mkdir -p ${DIRECTORY}

    # mount at the target directory
    sudo mount /dev/mapper/${ENCRYPT_LABEL} ${DIRECTORY}

    # need to get the UUID from encrypted meta data
    TMP_RESULT=$(sudo cryptsetup luksDump ${MOUNTPATH} | grep "UUID" | awk '{print $2}')
    ENCRYPT_UUID="UUID="${TMP_RESULT}

    # add to the crypttab to allow us to mount this automatically at boot time
    CRYPTTAB_LINE="${ENCRYPT_LABEL} ${ENCRYPT_UUID} /etc/dcLuks/${KEYNAME} luks"
    if ! (grep -q "${CRYPTTAB_LINE}" /etc/crypttab); then
        echo "${CRYPTTAB_LINE}" | sudo tee -a /etc/crypttab
    fi

    # add to fstab to mount on boot
    FSTAB_LINE="/dev/mapper/${ENCRYPT_LABEL}   ${DIRECTORY}     ext4    defaults,comment=encrypted 0       2"
    if ! (grep -q "$FSTAB_LINE" /etc/fstab); then
        echo "$FSTAB_LINE" | sudo tee -a /etc/fstab
    fi
}

# make use of attached db, xlog, and backup volumes if they exist, otherwise use instance-attached ssd
if [ -b /dev/xvdg ]; then
    mount-volume "/dev/xvdg" ${MAIN_MOUNT_PATH}
else
    if [ -b /dev/nvme0n1 ]; then
        ENCRYPT_FS="yes"
        mount-volume "/dev/nvme0n1" "/media/data/"  ${ENCRYPT_FS}
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
