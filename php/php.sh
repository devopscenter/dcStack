#!/bin/bash - 
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
#  ORGANIZATION: devops.center
#       CREATED: 03/21/2017 10:39:14
#      REVISION:  ---
#===============================================================================

#set -o nounset           # Treat unset variables as an error
set -o errexit            # exit immediately if command exists with a non-zero status
set -x                    # essentially debug mode

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
sudo apt-fast -y install php                  \
                         php7.0.common        \
                         php7.0-fpm           \
                         php7.0-curl          \
                         php7.0-cli           \
                         php7.0-pgsql         \
                         php7.0-gd            \
                         php7.0-mbstring      \
                         php7.0-soap          \
                         php7.0-simplexml

dcLog "done"



#-------------------------------------------------------------------------------
# and now get and set up composer the php package manager
#-------------------------------------------------------------------------------
dcLog "installing and setting up composer - php package manager"

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"

if [[ -f composer.phar ]]; then
    sudo mv composer.phar /usr/local/bin/composer
fi

dcLog "done"


dcEndLog "Finished php.sh"
