#!/bin/bash -ev

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
    pip install -r requirements.txt > /dev/null
    popd
popd
