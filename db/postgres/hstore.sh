#!/bin/bash

echo "CREATE EXTENSION hstore;" | \
    /bin/bash -c "/usr/lib/postgresql/9.4/bin/postgres --single \
    -D /var/lib/postgresql/9.4/main \
    -c config_file=$POSTGRES_CONF \
    template1"
