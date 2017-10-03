#!/bin/bash


source /usr/local/bin/dcEnv.sh                       # initalize logging environment

dcStartLog "install of app-specific web for ab0000 (basic Jenkins)"

pushd ../../buildtools/jenkins/
./jenkins-install.sh
popd

sudo pip install -r requirements.txt

#
# disable unused services (at least initially)
#
sudo mv /etc/supervisor/conf.d/nginx.conf /etc/supervisor/conf.d/nginx.save
sudo mv /etc/superviosr/conf.d/uwsgi.conf /etc/supervisor/conf.d/uwsgi.save
sudo mv /etc/supervisor/conf.d/pgpool.conf /etc/supervisor/conf.d/pgpool.save


dcEndLog "install of app-specific web for ab0000 (basic Jenkins)"
