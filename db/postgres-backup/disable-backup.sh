#!/usr/bin/env bash
#===============================================================================
#
#          FILE: disable-backup.sh
#
#         USAGE: disable-backup.sh
#
#   DESCRIPTION: script to look for and turn off postgres backups
#                by the CREATE INDEX lines in the customer appname .sql file
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

# remove cron entry for backup, if it exists
if (sudo crontab -l -u postgres|grep '^[^#].*pg_backup_rotated\.sh\b.*'); then
  sudo sed -i 's/^[^#].*pg_backup_rotated\.sh\b.*/#&/g' /var/spool/cron/crontabs/postgres
else
  echo "Backup not enabled.  No changes made."
fi
