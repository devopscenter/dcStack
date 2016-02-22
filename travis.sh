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
sudo /etc/init.d/postgresql stop
sudo apt-get --purge remove postgresql\*
sudo rm -rf /etc/postgresql/
sudo rm -rf /etc/postgresql-common/
sudo rm -rf /var/lib/postgresql/
sudo userdel -r postgres
#sudo groupdel postgres
./postgres.sh > /dev/null
popd
