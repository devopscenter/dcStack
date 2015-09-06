#!/bin/bash -e

export REDIS_VERSION=3.0.3
export REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz

sudo groupadd -r redis && sudo useradd -r -g redis redis

sudo apt-fast update && apt-fast install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

sudo gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

buildDeps='gcc libc6-dev make' \
    && set -x \
    && sudo apt-fast update && sudo apt-fast install -y $buildDeps --no-install-recommends \
    && sudo rm -rf /var/lib/apt/lists/* \
    && sudo mkdir -p /usr/src/redis \
    && pushd /tmp
    && curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
    && echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    && make -C /usr/src/redis \
    && sudo make -C /usr/src/redis install \
    && rm -rf /usr/src/redis \
    && apt-get purge -y --auto-remove $buildDeps

sudo mkdir /redisdata && chown redis:redis /redisdata

