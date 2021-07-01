#!/usr/bin/env bash
#===============================================================================
#
#          FILE: web.sh
#
#         USAGE: web.sh
#
#   DESCRIPTION: install what is necessary grafana-prometheus web container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 06/04/2021 
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
#set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode


source /usr/local/bin/dcEnv.sh                       # initalize logging environment

dcStartLog "install of app-specific web for 1213d64-stack (dcMonitoring)"

# update 
sudo apt-get update

# install node
source ~/dcStack/buildtools/utils/node.sh

# install grafana
source ~/dcStack/monitoring/grafana-install.sh

# install prometheus
source ~/dcStack/monitoring/prometheus-install.sh

# install the python support libraries
sudo -H pip install -r requirements.txt

#
# disable unused services
#
if [[ -f /etc/supervisor/conf.d/uwsgi.conf ]]; then
    sudo mv /etc/supervisor/conf.d/uwsgi.conf /etc/supervisor/conf.d/uwsgi.save
fi

# cleanup
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

dcEndLog "install of app-specific web for 1213d64-stack (dcMonitoring)"
