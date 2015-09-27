#!/bin/bash -e

echo "CREATE EXTENSION hstore;" | \
    /usr/lib/postgresql/9.4/bin/postgres --single \
    -D ${POSTGRESDBDIR} \
    -c config_file=$POSTGRES_CONF \
    template1
