#! /bin/sh

### BEGIN INIT INFO
# Provides:          pgpool2
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Should-Start:      postgresql
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: start pgpool-II
# Description: pgpool-II is a connection pool server and replication
#              proxy for PostgreSQL.
### END INIT INFO

# where is psql (for status)
PSQL="/usr/bin/psql"

# pgpool configuration files directory
PREFIX_PGPOOL="/etc/pgpool2"

# Who to run the postmaster as, usually "postgres".  (NOT "root")
PGUSER=postgres

# Where is pgpool binary?
PGPOOL="/usr/local/bin/pgpool"

# pgpool logfile
PGPOOLLOG="/var/log/pgpool/pgpool.log"

# Sets the path to the pool_hba.conf configuration file
# default: /usr/local/etc/pool_hba.conf
PGPOOL_HBA_CONFIG_FILE="$PREFIX_PGPOOL/pool_hba.conf"

# Sets the path to the pgpool.conf configuration file
# defailt: /usr/local/etc/pgpool.conf
PGPOOL_CONFIG_FILE="$PREFIX_PGPOOL/pgpool.conf"

# Sets the path to the pcp.conf configuration file
# default: /usr/local/etc/pcp.conf)
PGPOOL_PCP_CONFIG_FILE="$PREFIX_PGPOOL/pcp.conf"

# How to stop pgPool-II when needed:
#Shutdown modes are:
#  smart       quit after all clients have disconnected
#  fast        quit directly, with proper shutdown
#  immediate   quit without complete shutdown; will lead to recovery on restart

PGPOOL_SHUTDOWN_MODE="fast"

## STOP EDITING HERE

# The path that is to be used for the script
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

PGPOOL_START=""
if [ $PGPOOL_HBA_CONFIG_FILE ]
then
  PGPOOL_START="$PGPOOL_START -a $PGPOOL_HBA_CONFIG_FILE "
fi

if [ $PGPOOL_CONFIG_FILE ]
then
  PGPOOL_START="$PGPOOL_START -f $PGPOOL_CONFIG_FILE "
fi

if [ $PGPOOL_PCP_CONFIG_FILE ]
then
  PGPOOL_START="$PGPOOL_START -F $PGPOOL_PCP_CONFIG_FILE "
fi

set -e

# Parse command line parameters.
case $1 in
  start)
         echo -n "Starting pgPool-II: "

         PID_FILE_NAME=`grep pid_file_name ${PGPOOL_CONFIG_FILE} | cut -d\' -f2`

         if ! [ -e /var/run/postgresql ]
         then
            mkdir -p /var/run/postgresql/
            chown $PGUSER.$PGUSER /var/run/postgresql/
         fi

         if ! [ -e $PID_FILE_NAME ]
         then
            #$PID_FILE_NAME doesnt exist, we must create it
            mkdir -p `dirname $PID_FILE_NAME`
            chown $PGUSER.$PGUSER `dirname $PID_FILE_NAME`
         fi

         su - $PGUSER -c "$PGPOOL $PGPOOL_START -n &" >>$PGPOOLLOG 2>&1
         echo "ok!"
;;
  stop)
         echo -n "Stopping pgPool-II: "
         su - $PGUSER -c "$PGPOOL $PGPOOL_START -m '$PGPOOL_SHUTDOWN_MODE' stop &" >>$PGPOOLLOG 2>&1
         echo "ok!"
;;
  restart)
         echo -n "Restarting pgPool-II: "
         su - $PGUSER -c "$PGPOOL $PGPOOL_START -m '$PGPOOL_SHUTDOWN_MODE' stop &" >>$PGPOOLLOG 2>&1
         su - $PGUSER -c "$PGPOOL $PGPOOL_START -n &" >>$PGPOOLLOG 2>&1
         echo "ok"
;;
  reload)      
        echo -n "Reloading pgPool-II: "
        su - $PGUSER -c "$PGPOOL $PGPOOL_START -m '$PGPOOL_SHUTDOWN_MODE' reload &" >>$PGPOOLLOG 2>&1
        echo "ok!"
;;
  status)
        echo "Status of pgpool-II: "
        PGPOOL_PORT=`grep "^\(\ *\)port\(.*\)=" $PGPOOL_CONFIG_FILE | cut -\d= -f2 ` 
        PGPOOL_SOCK=`grep "^\(\ *\)socket_dir\(.*\)=" $PGPOOL_CONFIG_FILE | cut -\d= -f2 `
	echo "$PSQL -h $PGPOOL_SOCK -p $PGPOOL_PORT -U $PGUSER -c \"show pool_nodes\""
        su - $PGUSER -c "$PSQL -h $PGPOOL_SOCK -p $PGPOOL_PORT -U $PGUSER -c \"show pool_nodes\""
;;
  *)
# Print help
echo "Usage: $0 {start|stop|restart|reload|status}" 1>&2
exit 1
;;
esac

exit 0
