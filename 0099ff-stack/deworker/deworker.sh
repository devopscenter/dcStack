#!/usr/bin/env bash
#===============================================================================
#
#          FILE: dataengine.sh
#
#         USAGE: dataengine.sh
#
#   DESCRIPTION: install what is necessary for the dataengine container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 04/28/20 1
#      REVISION:  ---
#
# Copyright 2014-2020 devops.center llc
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
set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific dataengine worker for 0099ff"

# create the log directory where node can write its output for remote-syslog2 to pick up
sudo mkdir -p /data/deploy/logs
sudo chmod 777 /data/deploy/logs

# install remote_syslog2
curl -SLO https://github.com/papertrail/remote_syslog2/releases/download/v0.20/remote_syslog_linux_amd64.tar.gz
tar xvf remote_syslog_linux_amd64.tar.gz
cd remote_syslog
sudo cp ./remote_syslog /usr/local/bin

dcEndLog "install of app-specific dataengine worker for 0099ff"
