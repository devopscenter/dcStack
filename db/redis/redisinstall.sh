#!/bin/bash -evx

export REDIS_VERSION=3.0.3
export REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz

sudo apt-get -qq update && apt-get -y install python-software-properties software-properties-common && \
        sudo add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
            sudo apt-get -qq update

sudo add-apt-repository ppa:saiarcot895/myppa && \
        sudo apt-get -qq update && \
            sudo apt-get -qq -y install apt-fast

sudo groupadd -r redis && sudo useradd -r -g redis redis

sudo apt-fast -qq update && apt-fast -qq install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

sudo gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

buildDeps='gcc libc6-dev make'
set -x \
&& sudo apt-fast -qq update && sudo apt-fast -qq install -y $buildDeps --no-install-recommends \
&& sudo rm -rf /var/lib/apt/lists/* \
&& sudo mkdir -p /usr/src/redis \
&& pushd /tmp \
&& curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
#&& echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
&& tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
&& rm redis.tar.gz \
&& pushd /usr/src/redis
&& make --silent \
&& sudo make --silent install \
&& rm -rf /usr/src/redis \
&& apt-get purge -y --auto-remove $buildDeps

sudo mkdir -p /etc/redis
sudo curl -sSL https://raw.githubusercontent.com/antirez/redis/$REDIS_VERSION/redis.conf -o /etc/redis/redis.conf
sudo mkdir /redisdata 
sudo chown redis:redis /redisdata

