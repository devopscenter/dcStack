#!/usr/bin/env bash
#===============================================================================
#
#          FILE: run_php-fpm.sh
#
#         USAGE: run_php-fpm.sh
#
#   DESCRIPTION: setup php-fpm
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
#set -x             # essentially debug mode
 
# This script is run by Supervisor to start php-fpm 
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="PHP 7.0 FastCGI Process Manager"
NAME=php-fpm7.0
CONFFILE=/etc/php/7.0/fpm/php-fpm.conf
DAEMON=/usr/sbin/$NAME
DAEMON_ARGS="--daemonize --fpm-config $CONFFILE"
CONF_PIDFILE=$(sed -n 's/^pid[ =]*//p' $CONFFILE)
PIDFILE=${CONF_PIDFILE:-/run/php/php7.0-fpm.pid}
TIMEOUT=30

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

#
# Function to check the correctness of the config file
#
do_check()
{
	# Create the socket directory, if it doesn't already exist.

	if [ ! -e /var/run/php ]; then
		sudo install -d -m 755 -o php /var/run/php/
	fi

    /usr/lib/php/php7.0-fpm-checkconf || return 1
    return 0
}

#
# Function that starts the daemon/service
#
do_start()
{
        # Return
        #   0 if daemon has been started
        #   1 if daemon was already running
        #   2 if daemon could not be started
        start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON --test > /dev/null \
                || return 1
        start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON -- \
                $DAEMON_ARGS 2>/dev/null \
                || return 2
        # Add code here, if necessary, that waits for the process to be ready
        # to handle requests from services started subsequently which depend
        # on this one.  As a last resort, sleep for some time.
}

if [[ do_check -eq 0 ]]; then
	if [[ do_start -ne 1 ]]; then
		echo "ERROR: Attempting to start php-fpm failed."
        exit 1
	fi
else
	echo "ERROR: The checks before starting php-fpm failed exiting..."
	exit 1
fi
