#!/usr/bin/env bash
#===============================================================================
#
#          FILE: redisinstall.sh
#
#         USAGE: redisinstall.sh
#
#   DESCRIPTION: script to install redis on an instance/container
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
set -x             # essentially debug mode
set -o verbose

export REDIS_VERSION=5.0.5
export REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz

sudo apt -qq update && sudo apt -y install python-software-properties software-properties-common && \
        sudo add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
            sudo apt -qq update

sudo add-apt-repository -y ppa:saiarcot895/myppa && \
        sudo apt -qq update

sudo groupadd -r redis && sudo useradd -r -g redis redis

sudo apt -qq update && sudo apt -qq install -y --no-install-recommends \
    ca-certificates \
    curl \
    && sudo rm -rf /var/lib/apt/lists/*

sudo gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

buildDeps='gcc libc6-dev make'
set -x \
&& sudo apt -qq update && sudo apt -qq install -y $buildDeps --no-install-recommends \
&& sudo rm -rf /var/lib/apt/lists/* \
&& sudo mkdir -p /usr/src/redis \
&& pushd /tmp \
&& sudo curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
&& sudo tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
&& sudo rm -rf redis.tar.gz \
&& pushd /usr/src/redis \
&& sudo make --silent \
&& sudo make --silent install \
&& sudo rm -rf /usr/src/redis \
&& sudo apt purge -y --auto-remove $buildDeps \
&& popd \
&& popd

sudo mkdir -p /etc/redis
sudo curl -sSL https://raw.githubusercontent.com/antirez/redis/$REDIS_VERSION/redis.conf -o /etc/redis/redis.conf
sudo mkdir -p /media/data/redis/data
sudo chown redis:redis /media/data/redis /media/data/redis/data

# comment out the bind 127.0.0.1 in /etc/redis/redis.conf
sudo sed -e '/^bind 127.0.0.1/ s/bind 127.0.0.1/#bind 127.0.0.1/' -i /etc/redis/redis.conf

sudo cat conf/redis.conf | sudo tee --append /etc/redis/redis.conf
sudo cp conf/supervisor-redis.conf /etc/supervisor/conf.d/redis.conf

# Restart supervisor (if running) so that it reads in the new config.
# Note that supervisor not running if constructing a container image.
if sudo /etc/init.d/supervisor restart; then
  echo "supervisor restarted"
else
  echo "supervisor not restarted, as it was not running"
  exit 0
fi
