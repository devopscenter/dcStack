#!/bin/bash -evx

POSTGRES_VERSION=9.4
POSTGRESDBDIR=/media/data/postgres/db
POSTGRESBINDIR=/usr/lib/postgresql/${POSTGRES_VERSION}/bin

POSTGRES_CONF=${POSTGRESDBDIR}/postgresql.conf
POSTGRES_PERF_CONF=${POSTGRESDBDIR}/postgresql.conf.perf
POSTGRES_WALE_CONF=${POSTGRESDBDIR}/postgresql.conf.wale
