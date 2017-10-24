#!/usr/bin/env bash
#===============================================================================
#
#          FILE: dcEnv.sh
# 
#         USAGE: ./dcEnv.sh 
# 
#   DESCRIPTION: script to include in other scripts that set up the environment
#                and provides some basic utility functions
#                NOTE: this script differs from the one in dcUils in that this is
#                meant for instances that do not know about a shared drive.
#                And doesn't have the function to track events
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 03/21/2017 12:02:46
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

dcLog()
{
    msg=$1
    state=$2

    scriptName=$(basename -- "$0")
    TIMESTAMP=$(date +%F_%T)

    if [[ ! -z ${state} ]]; then
        echo "[${TIMESTAMP}]:${scriptName}:${state}:${msg}"
    else
        echo "[${TIMESTAMP}]:${scriptName}::${msg}"
    fi
}

dcStartLog()
{
    msg=$1
    dcLog "${msg}" "START"
}

dcEndLog()
{
    msg=$1
    dcLog "${msg}" "END"
}
