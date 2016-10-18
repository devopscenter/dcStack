#!/bin/bash -evx

PGVERSION=$1

# default postgres version to install
POSTGRES_VERSION=9.4

# If the version number is specified, then override the default version number.
if [ -n "$PGVERSION" ]; then
  POSTGRES_VERSION=${PGVERSION}
fi

echo "pgversion: "+$PGVERSION "postgres_version: "+$POSTGRES_VERSION

POSTGRES_MOUNT=/media/data/postgres

POSTGRESDBDIR=${POSTGRES_MOUNT}/db/pgdata
POSTGRESBINDIR=/usr/lib/postgresql/${POSTGRES_VERSION}/bin
POSTGREX_XLOG=${POSTGRES_MOUNT}/xlog/transactions

POSTGRES_CONF=${POSTGRESDBDIR}/postgresql.conf
POSTGRES_PERF_CONF=${POSTGRESDBDIR}/postgresql.conf.perf
POSTGRES_WALE_CONF=${POSTGRESDBDIR}/postgresql.conf.wale
