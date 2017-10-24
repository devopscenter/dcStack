#!/usr/bin/env bash
#===============================================================================
#
#          FILE: web.sh
# 
#         USAGE: web/web.sh
# 
#   DESCRIPTION: 66ccff stack, install web-specific components.
# 
#       OPTIONS: ===
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Bob Lozano, bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: long time ago
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

SCRATCHVOLUME=$1

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific web for 66ccff"

# Some equired packages for rendering
sudo apt-fast -y install libfontconfig-dev libxrender-dev libxtst6

# install node
curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -
sudo apt-get install -y nodejs
curl -L https://npmjs.com/install.sh | sudo sh
sudo npm install -g less

# Install required packages
sudo pip install -r requirements.txt

# 
# Required directories for this app. Note that this app requires a /media/data mountpoint prior to the execution
# of this script, whether provided by docker-compose (in containers) or by the instance creation.
# While simply creating a /media/data directory in the case where there is no temp volume would permit the app to run,
# the lackof space on the normal root volume would result in app failure fairly soon.
# Consequently, the best solution for this app is to simply specify an adequate scratch volume, mounted on /media/data.
#
if [[ "${SCRATCHVOLUME}" == "true" ]]; then
    sudo mkdir -p /media/data
    sudo ln -s /media/data /data/media 
fi

sudo mkdir -p /data/media/pdfcreator /data/media/reports/pdf


sudo chmod 777 -R /media/data/pdfcreator
sudo chmod 777 -R /media/data/reports

dcEndLog "install of app-specific web for 66ccff"
