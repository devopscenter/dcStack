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

export GIT_VERSION=2.31.1

sudo apt-get -qq update
sudo apt-get -qq -y install build-essential
sudo apt-get -qq -y install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev libffi-dev

pushd /tmp
sudo wget --quiet https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz
sudo tar -xvf git-${GIT_VERSION}.tar.gz
pushd git-${GIT_VERSION}
sudo make --silent prefix=/usr/local all && sudo make --silent prefix=/usr/local install
popd
popd

sudo apt-get -qq -y install sqlite3 libsqlite3-dev libssl-dev zlib1g-dev libxml2-dev libxslt-dev libbz2-dev gfortran libopenblas-dev liblapack-dev libatlas-dev subversion
sudo pip install -U setuptools-git wheel

sudo mkdir -p /wheelhouse

# Create a scratch directory, if it doesn't already exist
if [[ ! -e /data/scratch ]]; then
    sudo mkdir -p /data/scratch
    sudo chmod -R 777 /data/scratch
fi

echo "============================ Finished element: python ===================="
