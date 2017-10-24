#!/usr/bin/env bash
#===============================================================================
#
#          FILE: worker.sh
# 
#         USAGE: worker/worker.sh  COMBINED_WEBANDWORKER
# 
#   DESCRIPTION: 66ccff stack, install worker-specific components.
# 
#       OPTIONS: if COMBINED_WEBANDWORKER="true", then web and worker on a single instance/container; otherwise, separate instances/containers.
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
#set -x             # essentially debug mode

source /usr/local/bin/dcEnv.sh                       # initalize logging environment

COMBINED_WEB_WORKER="${1}"

dcStartLog "install of app-specific worker for 66ccff, combo: ${COMBINED_WEB_WORKER}"

sudo useradd celery

#
# If this is purely a worker, then we don't need uwsgi (this app still requires nginx, though with a specialized config)
#

if [[ "${COMBINED_WEB_WORKER}" == "true" ]]; then
	sudo cp conf/nginx-combo.conf /usr/local/nginx/conf/nginx.conf
elif [[ "${COMBINED_WEB_WORKER}" == "false" ]]; then
    sudo rm -rf /etc/supervisor/conf.d/uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/run_uwsgi.conf
    sudo cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
fi

#
# Setup supervisor to run flower and celery
#
sudo cp conf/supervisor-flower.conf /etc/supervisor/conf.d/flower.conf 
sudo cp conf/supervisor-celery.conf /etc/supervisor/conf.d/celery.conf
sudo cp conf/run_*.sh /etc/supervisor/conf.d/


dcEndLog "install of app-specific worker for 66ccff, combo: ${COMBINED_WEB_WORKER}"

