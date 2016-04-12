#!/bin/sh
 
# This script is run by Supervisor to start PostgreSQL in foreground mode
 
if [ -d /var/run/postgresql ]; then
    chmod -R 2775 /var/run/postgresql /var/run/postgresql/postgres-main.pg_stat_tmp
else
    install -d -m 2775 -o postgres -g postgres /var/run/postgresql
    install -d -m 2775 -o postgres -g postgres /var/run/postgresql/postgres-main.pg_stat_tmp
fi

exec su postgres -c '/usr/lib/postgresql/9.5/bin/postgres -D /media/data/postgres/db/pgdata -c config_file=/media/data/postgres/db/pgdata/postgresql.conf'

