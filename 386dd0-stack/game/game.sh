#!/usr/bin/env bash
#===============================================================================
#
#          FILE: worker.sh
#
#         USAGE: worker.sh
#
#   DESCRIPTION: install what is necessary for the worker container.
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
# set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode

#
# App-specific worker install for 386dd0
#
COMBINED_WEB_WORKER="${1}"
SCRATCHVOLUME="{$2}"

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of game instance for 386dd0."

# other installs
sudo add-apt-repository ppa:jonathonf/ffmpeg-3
sudo apt-get -y install ffmpeg

if [[ ! -d /media/data ]]; then
    sudo mkdir -p /media/data
fi


#sudo pip install -r requirements.txt

dcEndLog "End: install of game instance for 386dd0."
