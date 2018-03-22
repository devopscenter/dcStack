#!/usr/bin/env bash
#===============================================================================
#
#          FILE: web.sh
#
#         USAGE: web.sh
#
#   DESCRIPTION: installs what is necessary for the web container
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
set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode

#
# App-specific web install for 765ae2
#

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific web for 765ae2"


curl -sL https://deb.nodesource.com/setup_9.x | sudo bash -

sudo apt-get install -y nodejs

sudo apt-get install -y build-essential 

# and install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn

# scratch volume
sudo mkdir -p /media/data

#
# disable unused services
#
sudo mv /etc/supervisor/conf.d/uwsgi.conf /etc/supervisor/conf.d/uwsgi.save

dcEndLog "install of app-specific web for 765ae2"
