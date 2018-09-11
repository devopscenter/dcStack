#!/usr/bin/env bash
#===============================================================================
#
#          FILE: create-follower.sh
#
#         USAGE: create-follower.sh
#
#   DESCRIPTION: script to create a database follower
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 11/21/2016 15:13:37
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
#set -x             # essentially debug mode

PGMASTER_PRIVATEIP=$1
PGFOLLOWER_PRIVATEIP=$2
DNS_METHOD=$3

function etc_hosts_check
{
HOSTS_IP=$1
HOSTS_NAME=$2
TMP_ETC_HOSTS=$(mktemp -t etchosts.XXXXXX)
while read -r i; do
  # make sure it's not a comment
  if (echo "$i"|grep -vq "^#"); then
    # make sure it's not already in file
    if ! (echo "$i"|grep -q "^${HOSTS_IP}\b.*\b${HOSTS_NAME}\b"); then
      # if it's the only hostname entry for an IP, comment out the line
      if (echo "$i"|grep -Eq "^[0-9]+.[0-9]+.[0-9]+.[0-9]+\b[[:blank:]]*\b${HOSTS_NAME}\b[[:space:]]*$"); then
        echo "$i" | sed "s/^[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}[[:blank:]]*\b${HOSTS_NAME}\b[[:space:]]*$/#&/" | sudo tee -a "$TMP_ETC_HOSTS"
        continue
      # if other hostnames are associated with an IP, remove pgmaster-1 and any whitespace before it
      elif (echo "$i"|grep -Eq "^[0-9]+.[0-9]+.[0-9]+.[0-9]+\b[[:blank:]]*.*\b${HOSTS_NAME}\b[[:blank:]]*"); then
        echo "$i" | sed "s/[[:blank:]]*\b${HOSTS_NAME}\b//g" | sudo tee -a "$TMP_ETC_HOSTS"
        continue
      fi
    fi
  fi
  echo "$i" | sudo tee -a "$TMP_ETC_HOSTS" > /dev/null
done < /etc/hosts

if ! (grep -q "^${HOSTS_IP}\b.*\b${HOSTS_NAME}\b" "$TMP_ETC_HOSTS"); then
  echo "${HOSTS_IP} ${HOSTS_NAME}" | sudo tee -a "$TMP_ETC_HOSTS" > /dev/null
fi

cat "$TMP_ETC_HOSTS" | sudo tee /etc/hosts > /dev/null
rm -f "$TMP_ETC_HOSTS"
}

# skipped when using route53 for dns
if [[ "$DNS_METHOD" = 'etchosts' ]]; then
  etc_hosts_check "$PGMASTER_PRIVATEIP" pgmaster-1
  etc_hosts_check "$PGFOLLOWER_PRIVATEIP" pgstandby-1
fi

~/dcStack/db/postgres-standby/init-standby.sh

echo "trigger_file = '/media/data/postgres/trigger_promote'" | sudo tee -a /media/data/postgres/db/pgdata/recovery.conf

CRONTAB_OUTPUT=$(crontab -l 2>&1)
if [[ "${CRONTAB_OUTPUT}" != "no crontab"* ]]; then
    sudo sed -i "s/.*pg_backup_rotated/#&/" /var/spool/cron/crontabs/postgres
fi
