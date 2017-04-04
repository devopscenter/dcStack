#!/bin/sh
 
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

if [[ do_check ]]; then
	if [[ do_start ]]; then
		echo "ERROR: Attempting to start php-fpm failed."
        exit 1
	fi
else
	echo "ERROR: The checks before starting php-fpm failed exiting..."
	exit 1
fi
