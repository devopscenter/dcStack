#!/bin/bash -evx

POSTGRES_MOUNT=/media/data/postgres
POSTGRES_VERSION=9.5
POSTGRESDBDIR=${POSTGRES_MOUNT}/db/pgdata
POSTGRESBINDIR=/usr/lib/postgresql/${POSTGRES_VERSION}/bin
POSTGREX_XLOG=${POSTGRES_MOUNT}/xlog/transactions

POSTGRES_CONF=${POSTGRESDBDIR}/postgresql.conf
POSTGRES_PERF_CONF=${POSTGRESDBDIR}/postgresql.conf.perf
POSTGRES_WALE_CONF=${POSTGRESDBDIR}/postgresql.conf.wale
