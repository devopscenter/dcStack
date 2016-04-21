#!/bin/sh
 
# This script is run by Supervisor to start pgpool in foreground mode

# Create the socket directories, if it doesn't already exist.
 
if [ ! -d /var/run/pgpool ]; then
  install -d -m 2775 -o postgres -g postgres /var/run/pgpool
fi
if [ ! -d /var/run/postgresql ]; then
  install -d -m 2775 -o postgres -g postgres /var/run/postgresql
fi

exec /usr/local/bin/pgpool -a /etc/pgpool2/pool_hba.conf -f $1 -F /etc/pgpool2/pcp.conf -n
