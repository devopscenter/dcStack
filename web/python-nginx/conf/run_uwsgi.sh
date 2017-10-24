#!/usr/bin/env bash
#===============================================================================
#
#          FILE: run_uwsgi.sh
#
#         USAGE: run_uwsgi.sh
#
#   DESCRIPTION:
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

# This script is run by Supervisor to start UWSGI in foreground mode

# Create the socket directory, if it doesn't already exist.

if [ ! -e /var/run/uwsgi ]; then
    sudo install -d -m 755 -o uwsgi /var/run/uwsgi
fi

if [ -e /tmp/uwsgififo ]; then
    sudo rm /tmp/uwsgififo
fi

# Set default values for UWSGI configs

UWSGI_WORKERS=${UWSGI_WORKERS:-8}
UWSGI_MAX_REQUESTS=${UWSGI_MAX_REQUESTS:-5000}
UWSGI_BUFFER_SIZE=${UWSGI_BUFFER_SIZE:-4096}

exec /usr/local/opt/python/bin/uwsgi \
        --enable-threads \
        --master-fifo /tmp/uwsgififo \
        --workers=${UWSGI_WORKERS} \
        --max-requests=${UWSGI_MAX_REQUESTS} \
        --buffer-size=${UWSGI_BUFFER_SIZE} \
        --lazy-apps \
        --hook-post-fork="chdir:/data/deploy/current" \
        /data/deploy/current/uwsgi.ini
