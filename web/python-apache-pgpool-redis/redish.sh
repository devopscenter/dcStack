#!/bin/bash -e

#Need redis-cli and libs
pushd /tmp
wget http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz
tar xvzf redis-$REDIS_VERSION.tar.gz
pushd /redis-$REDIS_VERSION 
make -j 3 && sudo make install

