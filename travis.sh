#!/usr/bin/env bash
#===============================================================================
#
#          FILE: travis.sh
#
#         USAGE: travis.sh
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
set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode
set -o verbose

echo "PATH=/usr/local/opt/python/bin:$PATH" | sudo tee -a /etc/environment
. /etc/environment


docker-compose -f docker-compose-build.yml build

pushd buildtools/utils
./base-utils.sh
popd

pushd logging
./papertrail.sh
popd

pushd python
./python.sh > /dev/null
popd

pushd web/python-nginx
./nginx.sh > /dev/null
popd

pushd web/python-nginx-pgpool
./pgpool.sh > /dev/null
popd

pushd web/python-nginx-pgpool-libsodium
git clone https://github.com/devopsscion/libsodium-jni
git clone https://github.com/data-luminosity/message
    pushd libsodium-jni
    ./build-linux.sh > /dev/null
    popd

    pushd message
    sudo pip install -r requirements.txt > /dev/null
    popd
popd

pushd db/postgres
sudo /etc/init.d/postgresql stop
sudo apt-get --purge remove postgresql\*
sudo rm -rf /etc/postgresql/
sudo rm -rf /etc/postgresql-common/
sudo rm -rf /var/lib/postgresql/
sudo userdel -r postgres
#sudo groupdel postgres
#./postgres.sh > /dev/null
popd
