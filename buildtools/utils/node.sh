#!/usr/bin/env bash
#===============================================================================
#
#          FILE: node.sh
#
#         USAGE: ./node.sh
#
#   DESCRIPTION: script to install the latest version of node and any other
#                utilities that need to be installed with it.  Like the 
#                module/package installer
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Bob Lozano - bob@devops.center
#                Gregg Jensen - gjensen@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 03/13/2018 12:44:58
#      REVISION: 04/28/2020
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
#set -o errexit     # exit immediately if command exits with a non-zero status
#set -o verbose     # print the shell lines as they are executed
set -x             # essentially debug mode

echo "============================ Building element: node ===================="
 
# latest node as of 04/28/20
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -

# NOTE on ubuntu the package name is nodejs as is the executable
sudo apt install -y nodejs

# and some npm modules will need the essentials so install them if they aren't
# already there
sudo apt install build-essential

echo "============================ Finished element: base ===================="
