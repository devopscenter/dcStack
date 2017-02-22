#!/bin/bash -evx

export REDIS_VERSION=3.0.7
export REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz

sudo apt-get -qq update && sudo apt-get -y install python-software-properties software-properties-common && \
        sudo add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
            sudo apt-get -qq update

sudo add-apt-repository -y ppa:saiarcot895/myppa && \
        sudo apt-get -qq update && \
            sudo apt-get -qq -y install apt-fast

sudo groupadd -r redis && sudo useradd -r -g redis redis

sudo apt-fast -qq update && sudo apt-fast -qq install -y --no-install-recommends \
    ca-certificates \
    curl \
    && sudo rm -rf /var/lib/apt/lists/*

sudo gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

buildDeps='gcc libc6-dev make'
set -x \
&& sudo apt-fast -qq update && sudo apt-fast -qq install -y $buildDeps --no-install-recommends \
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
&& sudo apt-get purge -y --auto-remove $buildDeps \
&& popd \
&& popd

sudo mkdir -p /etc/redis
sudo curl -sSL https://raw.githubusercontent.com/antirez/redis/$REDIS_VERSION/redis.conf -o /etc/redis/redis.conf
sudo mkdir -p /media/data/redis/data
sudo chown redis:redis /media/data/redis/data

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
