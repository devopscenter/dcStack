#!/bin/bash -e

echo "CREATE EXTENSION hstore;" | \
    ${POSTGRESBINDIR}/postgres --single \
    -D ${POSTGRESDBDIR} \
    -c config_file=$POSTGRES_CONF \
    template1
