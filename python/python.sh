#!/usr/bin/env bash
#===============================================================================
#
#          FILE: python.sh
#
#         USAGE: python.sh
#
#   DESCRIPTION: install common utils for python apps, beyond what is in base_utils.sh.
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
set -o errexit      # exit immediately if command exits with a non-zero status
set -x             # essentially debug mode
set -o verbose

echo "============================ Building element: python ===================="
echo "PATH=/usr/local/opt/python/bin:$PATH" | sudo tee -a /etc/environment

sudo mkdir -p /wheelhouse

# Create a scratch directory, if it doesn't already exist
if [[ ! -e /data/scratch ]]; then
    sudo mkdir -p /data/scratch
    sudo chmod -R 777 /data/scratch
fi

echo "============================ Finished element: python ===================="
