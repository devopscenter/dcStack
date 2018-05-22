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

PHP_VERSION=7.0
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
dcLog "done"

#-------------------------------------------------------------------------------
# install php and the appropriate other needed packages
#-------------------------------------------------------------------------------
dcLog "installing php and accompanying extensions"
sudo apt-fast -y install php${PHP_VERSION}               \
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
                         php-mongodb

dcLog "done"



#-------------------------------------------------------------------------------
# and now get and set up composer the php package manager
#-------------------------------------------------------------------------------
dcLog "installing and setting up composer - php package manager"

mkdir /tmp/composer
cd /tmp/composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod a+x /usr/local/bin/composer
#php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#php composer-setup.php
#php -r "unlink('composer-setup.php');"

#if [[ -f composer.phar ]]; then
#    sudo mv composer.phar /usr/local/bin/composer
#fi

dcLog "done"


dcEndLog "Finished php.sh"
