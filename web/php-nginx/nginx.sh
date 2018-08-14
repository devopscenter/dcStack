#!/usr/bin/env bash
#===============================================================================
#
#          FILE: nginx.sh
#
#         USAGE: ./nginx.sh
#
#   DESCRIPTION: installation and set up of nginx
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 03/21/2017 11:33:15
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

echo "============================ Beginning element: nginx_php ===================="
#-------------------------------------------------------------------------------
# START set up the logging framework
#-------------------------------------------------------------------------------
dcENV_FILE="/usr/local/bin/dcEnv.sh"
if [[ -e "${dcENV_FILE}" ]]; then
    source "${dcENV_FILE}"
else
    dcLog(){ echo "${1}"; }
    dcStartLog(){ dcLog "${1}"; }
    dcEndLog(){ dcLog "${1}"; }
fi
#-------------------------------------------------------------------------------
# END setting up the logging framework
#-------------------------------------------------------------------------------

dcStartLog "Starting nginx.sh"

dcLog "set the nginx version number in environment variable"
. nginx-php-env.sh


#-------------------------------------------------------------------------------
# install rsyslog-gnutls
#-------------------------------------------------------------------------------
dcLog "installing rsyslog-gnutls"

sudo apt-fast install -y rsyslog-gnutls

dcLog "done"


#-------------------------------------------------------------------------------
# install perl extention
#-------------------------------------------------------------------------------
dcLog "setting up perl (pcre)"
pushd /tmp
wget --quiet ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.39.tar.bz2 && \
    tar -xvf pcre-8.39.tar.bz2
pushd pcre-8.39 
./configure && make --silent -j 3 && sudo make --silent install
popd
dcLog "done"

dcLog "geting and installing nginx"
wget --quiet http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && tar -xvf nginx-$NGINX_VERSION.tar.gz
pushd nginx-$NGINX_VERSION 
./configure --with-http_stub_status_module --with-http_ssl_module && sudo make --silent -j 3 && sudo make --silent install
popd
dcLog "done"

dcLog "installing libgeos-dev"
sudo apt-fast install -y libgeos-dev
popd
dcLog "done"

dcLog "setting openssl params"
#http://security.stackexchange.com/questions/95178/diffie-hellman-parameters-still-calculating-after-24-hours
pushd /etc/ssl/certs
sudo openssl dhparam -dsaparam -out dhparam.pem 2048
popd
dcLog "done"

#-------------------------------------------------------------------------------
# copy the appropriate edited configs 
#-------------------------------------------------------------------------------
dcLog "copying the needed php configuration files"
sudo cp conf/php.ini /etc/php/${PHP_VERSION}/fpm/
sudo cp conf/php-fpm.conf /etc/php/${PHP_VERSION}/fpm/
sudo cp conf/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/
sudo cp conf/supervisor-php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf

dcLog "copying the needed nginx configuration files"
sudo cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
sudo cp conf/supervisor-nginx.conf /etc/supervisor/conf.d/nginx.conf
dcLog "done"

echo "============================ Finished element: nginx_php ===================="
dcEndLog "Finished nginx.sh set up and configuration"
