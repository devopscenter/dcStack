#!/bin/bash -ev

pushd python
./python.sh
popd

pushd web/python-nginx
./nginx.sh
popd

pushd web/python-nginx-pgpool
./pgpool.sh
popd

pushd web/python-nginx-pgpool-libsodium
git clone https://github.com/devopsscion/libsodium-jni
git clone https://github.com/data-luminosity/message
    pushd libsodium-jni
    ./dependencies-linux.sh
    ./build.sh
    popd

    pushd message
    pip install -r requirements.txt
    popd
popd
