#!/usr/bin/env bash
#===============================================================================
#
#          FILE: web.sh
#
#         USAGE: web.sh
#
#   DESCRIPTION: install was is necessary for the web container
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
# Copyright 2014-2021 devops.center llc
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


# Manually switch to python2 for this app stack
pushd ../../python/
. ../web/python-nginx/nginxenv.sh

./python2.7.sh
sudo pip2 install uwsgi==$UWSGI_VERSION && \
    sudo mkdir -p /var/log/uwsgi && \
    sudo chown -R uwsgi /var/log/uwsgi
popd


sudo pip2 install -r requirements.txt
sudo pip2 install --no-binary :all: -r requirements2.txt
sudo pip2 install -r requirements3.txt

# scratch volume
sudo mkdir -p /media/data/tmp
sudo chmod 777 -R /media/data/tmp

dcEndLog "install of app-specific web for 0099ff"
