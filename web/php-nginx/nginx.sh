#!/bin/bash - 
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
#  ORGANIZATION: devops.center
#       CREATED: 03/21/2017 11:33:15
#      REVISION:  ---
#===============================================================================

#set -o nounset           # Treat unset variables as an error
set -o errexit            # exit immediately if command exists with a non-zero status
set -x                    # essentially debug mode

#-------------------------------------------------------------------------------
# START set up the logging framework
#-------------------------------------------------------------------------------
dcENV_FILE="../../dcEnv.sh"
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
. ./nginxenv.sh


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
sudo cp conf/php.ini /etc/php/7.0/fpm/
sudo cp conf/php-fpm.conf /etc/php/7.0/fpm/
sudo cp conf/www.conf /etc/php/7.0/fpm/pool.d/
sudo cp conf/supervisor-php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf
sudo cp conf/run_php-fpm.sh /etc/supervisor/conf.d/run_php-fpm.sh

dcLog "copying the needed nginx configuration files"
sudo cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
sudo cp conf/supervisor-nginx.conf /etc/supervisor/conf.d/nginx.conf
dcLog "done"

dcEndLog "Finished nginx.sh set up and configuration"
