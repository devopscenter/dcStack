#!/bin/bash -e

PGVERSION=$1
. ./postgresenv.sh $PGVERSION


echo "CREATE EXTENSION hstore;" | \
    ${POSTGRESBINDIR}/postgres --single \
    -D ${POSTGRESDBDIR} \
    -c config_file=$POSTGRES_CONF \
    template1
