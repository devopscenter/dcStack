#!/bin/bash -ev

echo "PATH=/usr/local/opt/python/bin:$PATH" | sudo tee -a /etc/environment
. /etc/environment

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
/etc/init.d/postgresql stop
apt-get --purge remove postgresql\*
rm -r /etc/postgresql/
rm -r /etc/postgresql-common/
rm -r /var/lib/postgresql/
userdel -r postgres
groupdel postgres
./postgres.sh > /dev/null
popd
