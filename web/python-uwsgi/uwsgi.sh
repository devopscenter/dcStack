#!/usr/bin/env bash
#===============================================================================
#
#          FILE: uwsgi.sh
#
#         USAGE: uwsgi.sh
#
#   DESCRIPTION: install uwsgi
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 05/25/2022 15:13:37
#      REVISION:  ---
#
# Copyright 2014-2022 devops.center llc
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

. ./uwsgienv.sh

sudo useradd uwsgi
sudo usermod -a -G sudo uwsgi
sudo cp conf/sudo-uwsgi /etc/sudoers.d

sudo apt-get install -y rsyslog-gnutls

#http://security.stackexchange.com/questions/95178/diffie-hellman-parameters-still-calculating-after-24-hours
cd /etc/ssl/certs && sudo openssl dhparam -dsaparam -out dhparam.pem 2048

sudo pip install uwsgi==$UWSGI_VERSION && \
    sudo mkdir -p /var/log/uwsgi && \
    sudo chown -R uwsgi /var/log/uwsgi
popd

sudo cp conf/supervisor-uwsgi.conf /etc/supervisor/conf.d/uwsgi.conf
sudo cp conf/run_uwsgi.sh /etc/supervisor/conf.d/run_uwsgi.sh
