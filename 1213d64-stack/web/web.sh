#!/usr/bin/env bash
#===============================================================================
#
#          FILE: web.sh
#
#         USAGE: web.sh
#
#   DESCRIPTION: install what is necessary for the web container
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


source /usr/local/bin/dcEnv.sh                       # initalize logging environment

dcStartLog "install of app-specific web for 1213d64-stack (dcMonitoring)"

# add the repository for grafana
curl https://packagecloud.io/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packagecloud.io/grafana/stable/debian/ stretch main"

# update and install grafana
sudo apt-get update

# make sure grafana will be installed from the packagecloud repository
apt-cache policy grafana

sudo apt-get install -y grafana

# install parallel shell for running paws
sudo apt-get install -y pdsh

# Install node
curl -sL https://deb.nodesource.com/setup_9.x | sudo bash -

sudo apt-get install -y nodejs

sudo apt-get install -y build-essential 

# install the python support libraries
sudo -H pip install -r requirements.txt

# Clone the statsd project 
git clone https://github.com/etsy/statsd.git

# Create a config file for statsd
cp ./statsd/exampleConfig.js ./statsd/config.js

# we need expect just in case paws is run with the -x option
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y expect
#
# disable unused services (at least initially)
#
if [[ -f /etc/supervisor/conf.d/nginx.conf ]]; then 
    sudo mv /etc/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.save
fi
if [[ -f /etc/supervisor/conf.d/uwsgi.conf ]]; then 
    sudo mv /etc/supervisor/conf.d/uwsgi.conf /etc/supervisor/conf.d/uwsgi.save
fi
if [[ -f /etc/supervisor/conf.d/pgpool.conf ]]; then 
    sudo mv /etc/supervisor/conf.d/pgpool.conf /etc/supervisor/conf.d/pgpool.save
fi

# set up the supervisor start script for grafana
pwd
sudo cp conf/supervisor-grafana.conf /etc/supervisor/conf.d/grafana.conf
sudo cp conf/run_grafana.sh /etc/supervisor/conf.d/
chmod a+x /etc/supervisor/conf.d/run_grafana.sh

dcEndLog "install of app-specific web for 1213d64-stack (dcMonitoring)"
