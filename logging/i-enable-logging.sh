#!/usr/bin/env bash
#===============================================================================
#
#          FILE: i-enable-logging.sh
#
#         USAGE: i-enable-loggging.sh
#
#   DESCRIPTION: NOTE: this is only run on an instance, not within a container.
#                      also, must be run after supervisor is installed.
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


echo "============================ Building element: logging ===================="
# Enable logging to papertrail through rsyslogd, using TLS and queueing
./papertrail.sh

# Set the papertrail destination in rsyslogd and supervisor.
./set-destination.sh
echo "============================ Finished element: logging ===================="

