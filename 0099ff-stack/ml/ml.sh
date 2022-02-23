#!/usr/bin/env bash
#===============================================================================
#
#          FILE: ml.sh
#
#         USAGE: ml.sh
#
#   DESCRIPTION: install was is necessary for the ml container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 02/21/22
#      REVISION:  ---
#
# Copyright 2014-2022 devops.center llc
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
dcStartLog "install of app-specific web for 0099ff"


# sudo pip install --no-binary :all: -r requirements1.txt

sudo pip install -r requirements1.txt
sudo pip install -r requirements2.txt

# scratch volume
sudo mkdir -p /media/data/tmp
sudo chmod 777 -R /media/data/tmp

dcEndLog "install of app-specific ml for 0099ff"
