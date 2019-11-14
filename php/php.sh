#!/usr/bin/env bash
#===============================================================================
#
#          FILE: php.sh
#
#         USAGE: ./php.sh
#
#   DESCRIPTION: Installs php and creates the php user
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 03/21/2017 10:39:14
#      REVISION:  ---
#
# Copyright 2014-2018 devops.center llc
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
set -o errexit            # exit immediately if command exists with a non-zero status
set -x                    # essentially debug mode
echo "============================ Building element: php ===================="

PHP_VERSION=5.6
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
dcStartLog "Starting php.sh"

#-------------------------------------------------------------------------------
# add and set up the php user
#-------------------------------------------------------------------------------
dcLog "set up user"
sudo useradd php
sudo usermod -a -G sudo php
sudo cp conf/sudo-php /etc/sudoers.d
dcLog "done"


#-------------------------------------------------------------------------------
# before loading do an update
#-------------------------------------------------------------------------------
dcLog "updating system with apt-get update"
sudo apt-get -qq update
sudo apt-get install -y software-properties-common
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
sudo apt-get -qq update
#sudo apt-key del 4F4EA0AAE5267A6C
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
dcLog "done"


#-------------------------------------------------------------------------------
# install php and the appropriate other needed packages
#-------------------------------------------------------------------------------
dcLog "installing php and accompanying extensions"
sudo apt-get -y install php${PHP_VERSION}               \
                         php${PHP_VERISON}.common        \
                         php${PHP_VERSION}-fpm           \
                         php${PHP_VERSION}-curl          \
                         php${PHP_VERSION}-cli           \
                         php${PHP_VERSION}-pgsql         \
                         php${PHP_VERSION}-gd            \
                         php${PHP_VERSION}-mbstring      \
                         php${PHP_VERSION}-soap          \
                         php${PHP_VERSION}-simplexml     \
                         php${PHP_VERSION}-zip           \
                         php${PHP_VERSION}-mcrypt        \
                         php${PHP_VERSION}-json          \
                         php${PHP_VERSION}-mysql         \
                         php-mongo

dcLog "done"



#-------------------------------------------------------------------------------
# and now get and set up composer the php package manager
#-------------------------------------------------------------------------------
dcLog "installing and setting up composer - php package manager"
sudo apt-get -y install php-cli php-mbstring


mkdir /tmp/composer
cd /tmp/composer
curl -sS https://getcomposer.org/installer -o composer-setup.php
#php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# stop the systemd service so that supervisor will control php
sudo systemctl stop php${PHP_VERSION}-fpm
# NOTE TODO possible use the mask instead of disable so that it can not be run
# manually or automatically.  It can be unmasked if needed though
sudo systemctl disable php${PHP_VERSION}-fpm

dcLog "done"


echo "============================ Finished element: php ===================="
dcEndLog "Finished php.sh"
