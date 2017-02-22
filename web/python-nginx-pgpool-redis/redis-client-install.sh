#!/bin/bash -ex

. ./redisclientenv.sh

#Need redis-cli and libs
#note that python client will need to be installed via pip in app-specific stack
pushd /tmp
wget --quiet http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz
tar xzf redis-$REDIS_VERSION.tar.gz
pushd redis-$REDIS_VERSION 
make --silent -j 3 && sudo make --silent install

