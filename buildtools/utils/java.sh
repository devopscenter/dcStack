#!/usr/bin/env bash
#===============================================================================
#
#          FILE: java.sh
#
#         USAGE: ./java.sh
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
#  ORGANIZATION: devops.center
#       CREATED: 04/28/20 
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
#set -o errexit     # exit immediately if command exits with a non-zero status
#set -o verbose     # print the shell lines as they are executed
set -x             # essentially debug mode

echo "============================ Building element: java ===================="
 
# install java
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt-get update
sudo apt-get install openjdk-11-jdk
java -version


echo "============================ Finished element: java ===================="
