#!/bin/bash

PGMASTER=$1
PGMASTER_PRIVATEIP=$2
PGFOLLOWER=$3
PGFOLLOWER_PRIVATEIP=$4

function etc_hosts_check
{
HOSTS_IP=$1
HOSTS_NAME=$2
TMP_ETC_HOSTS=$(mktemp -t etchosts.XXXXXX)
while read i; do
  # make sure it's not a comment
  if (echo "$i"|grep -vq "^#"); then
    # make sure it's not already in file
    if ! (echo "$i"|grep -q "^${HOSTS_IP}\b.*\b${HOSTS_NAME}\b"); then
      # if it's the only hostname entry for an IP, comment out the line
      if (echo "$i"|grep -Eq "^[0-9]+.[0-9]+.[0-9]+.[0-9]+\b[[:blank:]]*\b${HOSTS_NAME}\b[[:space:]]*$"); then
        echo "$i" | sudo sed "s/^[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}[[:blank:]]*\b${HOSTS_NAME}\b[[:space:]]*$/#&/" >> "$TMP_ETC_HOSTS"
        continue
      # if other hostnames are associated with an IP, remove postgresmaster_1 and any whitespace before it
      elif (echo "$i"|grep -Eq "^[0-9]+.[0-9]+.[0-9]+.[0-9]+\b[[:blank:]]*.*\b${HOSTS_NAME}\b[[:blank:]]*"); then
        echo "$i" | sudo sed "s/[[:blank:]]*\b${HOSTS_NAME}\b//g" >> "$TMP_ETC_HOSTS"
        continue
      fi
    fi
  fi
  echo "$i" | sudo tee -a "$TMP_ETC_HOSTS" > /dev/null
done < /etc/hosts

if ! (grep -q "^${HOSTS_IP}\b.*\b${HOSTS_NAME}\b" "$TMP_ETC_HOSTS"); then
  echo "${HOSTS_IP} ${HOSTS_NAME}" | sudo tee -a "$TMP_ETC_HOSTS" > /dev/null
fi

sudo cat "$TMP_ETC_HOSTS" > /etc/hosts
rm -f "$TMP_ETC_HOSTS"
}

etc_hosts_check "$PGMASTER_PRIVATEIP" "$PGMASTER" 
etc_hosts_check "$PGFOLLOWER_PRIVATEIP" "$PGFOLLOWER"

#
# is reboot actually necessary?
#

~/docker-stack/db/postgres-standby/init-standby.sh

# For promotion, add this to recovery.conf:
# trigger_file = '/media/data/postgres/trigger_promote'
#    (create that file with a “touch” to actually trigger the promote
echo "trigger_file = '/media/data/postgres/trigger_promote'" >> /media/data/postgres/db/pgdata/recovery.conf 
