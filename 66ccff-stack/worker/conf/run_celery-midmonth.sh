#!/usr/bin/env bash
#===============================================================================
#
#          FILE: run_celery-midmonth.sh
#
#         USAGE: run_celery-midmonth.sh
#
#   DESCRIPTION: run script for the celery queuq for midmonth
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
 
# This script is run by Supervisor to start celery in foreground mode

# Create the socket directories, if it doesn't already exist.
 
if [ ! -d /var/run/celery ]; then
    sudo mkdir /var/run/celery
    sudo chown celery:celery /var/run/celery
fi


# Create a worker for all queues
sudo -Eu celery /usr/local/opt/python/bin/python manage.py celery worker \
                                           --loglevel=INFO --soft-time-limit=36000  \
                                           -c 6 -Q processmidmonthqueue \
                                           -Ofair \
                                           -n process_midmonth@%n \
                                           --pidfile=/var/run/celery/process_midmonth.pid
