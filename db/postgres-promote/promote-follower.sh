#!/bin/bash

OLD_MASTER_PRIVATEIP=$1
OLD_FOLLOWER_PRIVATEIP=$2

# promote to master
sudo su -c "/usr/lib/postgresql/9.5/bin/pg_ctl promote -D /media/data/postgres/db/pgdata" -s /bin/sh postgres

# remove old follower ip/hostname
function etc_hosts_remove
{
OLD_HOSTS_IP=$1
OLD_HOSTS_NAME=$2
TMP_ETC_HOSTS=$(mktemp -t etchosts.XXXXXX)
while read -r i; do
  # make sure it's not a comment
  if (echo "$i"|grep -vq "^#"); then
    # if it's the only hostname entry for an IP, comment out the line
    if (echo "$i"|grep -Eq "^${OLD_HOSTS_IP}\b[[:blank:]]*\b${OLD_HOSTS_NAME}\b[[:space:]]*$"); then
      echo "$i" | sed "s/^${OLD_HOSTS_IP}[[:blank:]]*\b${OLD_HOSTS_NAME}\b[[:space:]]*$/#&/" | sudo tee -a "$TMP_ETC_HOSTS"
      continue
    # if other hostnames are associated with an IP, remove $OLD_HOSTS_NAME and any whitespace before it
    elif (echo "$i"|grep -Eq "^${OLD_HOSTS_IP}\b[[:blank:]]*.*\b${OLD_HOSTS_NAME}\b[[:blank:]]*"); then
      echo "$i" | sed "s/[[:blank:]]*\b${OLD_HOSTS_NAME}\b//g" | sudo tee -a "$TMP_ETC_HOSTS"
      continue
    fi
  fi
  echo "$i" | sudo tee -a "$TMP_ETC_HOSTS" > /dev/null
done < /etc/hosts
cat "$TMP_ETC_HOSTS" | sudo tee /etc/hosts > /dev/null
rm -f "$TMP_ETC_HOSTS"
}

etc_hosts_remove "$OLD_MASTER_PRIVATEIP" postgresmaster_1
etc_hosts_remove "$OLD_FOLLOWER_PRIVATEIP" postgresstandby_1

echo "${OLD_FOLLOWER_PRIVATEIP} postgressmaster_1" | sudo tee -a /etc/hosts > /dev/null
