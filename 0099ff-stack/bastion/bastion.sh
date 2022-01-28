#!/usr/bin/env bash
#===============================================================================
#
#          FILE: dataengine.sh
#
#         USAGE: dataengine.sh
#
#   DESCRIPTION: install what is necessary for the dataengine container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 04/28/20 1
#      REVISION:  ---
#
# Copyright 2014-2020 devops.center llc
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
dcStartLog "install of app-specific collector for 0099ff"


dcEndLog "install of app-specific collector for 0099ff"
