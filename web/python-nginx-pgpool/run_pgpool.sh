#!/bin/sh
 
# This script is run by Supervisor to start pgpool in foreground mode

# Create the socket directories, if it doesn't already exist.
 
if [ ! -d /var/run/pgpool ]; then
  sudo install -d -m 755 -o postgres -g postgres /var/run/pgpool
fi
if [ ! -d /var/run/postgresql ]; then
  sudo install -d -m 755 -o postgres -g postgres /var/run/postgresql
fi
# Make sure that pgpool does not read in any pre-existing status file, so that it will query backends on startup
# to see whether they are reachable or not. This is the preferred beahvior, UNLESS the pgpool config permits pgpool
# to initiate postgres follower promotions.

exec /usr/local/bin/pgpool -a /etc/pgpool2/pool_hba.conf -f $1 -F /etc/pgpool2/pcp.conf -n -D

