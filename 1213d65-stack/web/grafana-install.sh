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


grafana_version=8.0.0

# update 
sudo apt-get update

# add the grafana user
useradd grafana

# install grafana helper tool wizzy to help with exporting dashboards
npm install -g wizzy

# set up the location for the files
if [[ ! -d /opt ]]; then
    sudo mkdir /opt
    sudo chmod 777 /opt
fi
if [[ ! -d /usr/local/src ]]; then
    sudo mkdir -p /usr/local/src
    sudo chmod 777 /usr/local/src
fi

sudo mkdir -p /media/data/grafana
sudo chown grafana:grafana /media/data/grafana


# Install Grafana
sudo mkdir  -p /opt/grafana
curl https://dl.grafana.com/oss/release/grafana-${grafana_version}.linux-amd64.tar.gz -o /usr/local/src/grafana.tar.gz                                                                                  &&\
tar -xzvf /usr/local/src/grafana.tar.gz -C /opt/grafana --strip-components=1
rm /usr/local/src/grafana.tar.gz

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------

# Configure Grafana
cp conf/custom.ini /opt/grafana/conf/custom.ini

# set up the supervisor start script for grafana
sudo cp conf/supervisor-nginx.conf /etc/supervisor/conf.d/nginx.conf
sudo cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
sudo cp conf/supervisor-grafana.conf /etc/supervisor/conf.d/grafana.conf
sudo cp conf/run_grafana.sh /etc/supervisor/conf.d/run_grafana.sh
sudo chmod a+x /etc/supervisor/conf.d/run_grafana.sh

# update the PATH variable in the bashrc with the needed new paths 
echo "export PATH=/opt/grafana/bin:\$PATH" >> ~/.bashrc
