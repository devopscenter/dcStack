#!/usr/bin/env bash
#===============================================================================
#
#          FILE: worker.sh
#
#         USAGE: worker.sh
#
#   DESCRIPTION: installs what is needed for the worker container
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

COMBINED_WEB_WORKER="${1}"

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific worker for 000000, combo: ${COMBINED_WEB_WORKER}"

#
# If this is purely a worker, then we don't need nginx and uwsgi
#

if [[ "${COMBINED_WEB_WORKER}" = "false" ]]; then
    sudo rm -rf /etc/supervisor/conf.d/uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/run_uwsgi.conf
    sudo rm -rf /etc/supervisor/conf.d/nginx.conf 
fi

#
# Setup supervisor to run django-rq worker(s)
#
cp conf/supervisor-djangorq-worker.conf /etc/supervisor/conf.d/djangorq-worker.conf


dcEndLog "install of app-specific worker for 000000, combo: ${COMBINED_WEB_WORKER}"
