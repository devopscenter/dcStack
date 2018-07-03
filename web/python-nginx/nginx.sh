#!/usr/bin/env bash
#===============================================================================
#
#          FILE: nginx.sh
#
#         USAGE: nginx.sh
#
#   DESCRIPTION: install nginx
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 11/21/2016 15:13:37
#      REVISION:  ---
#
# Copyright 2014-2017 devops.center llc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#===============================================================================

#set -o nounset     # Treat unset variables as an error
#set -o errexit      # exit immediately if command exits with a non-zero status
set -x             # essentially debug mode

. ./nginxenv.sh

sudo useradd uwsgi
sudo usermod -a -G sudo uwsgi
sudo cp conf/sudo-uwsgi /etc/sudoers.d

sudo apt-fast install -y rsyslog-gnutls

pushd /tmp
wget --quiet ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.41.tar.bz2 && \
    tar -xvf pcre-8.41.tar.bz2
pushd pcre-8.41
./configure && make --silent -j 3 && sudo make --silent install
popd

wget --quiet http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && tar -xvf nginx-$NGINX_VERSION.tar.gz
pushd nginx-$NGINX_VERSION 
./configure --with-http_stub_status_module --with-http_ssl_module && sudo make --silent -j 3 && sudo make --silent install
popd

sudo apt-fast install -y libgeos-dev

#http://security.stackexchange.com/questions/95178/diffie-hellman-parameters-still-calculating-after-24-hours
cd /etc/ssl/certs && sudo openssl dhparam -dsaparam -out dhparam.pem 2048

sudo pip install uwsgi==$UWSGI_VERSION && \
    sudo mkdir -p /var/log/uwsgi && \
    sudo chown -R uwsgi /var/log/uwsgi
popd

sudo cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
sudo cp conf/supervisor-nginx.conf /etc/supervisor/conf.d/nginx.conf
sudo cp conf/supervisor-uwsgi.conf /etc/supervisor/conf.d/uwsgi.conf
sudo cp conf/run_uwsgi.sh /etc/supervisor/conf.d/run_uwsgi.sh
