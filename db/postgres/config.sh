#!/bin/bash -e

${POSTGRESBINDIR}/initdb -D ${POSTGRESDBDIR}

cat ./conf/hba.conf >> ${POSTGRESDBDIR}/pg_hba.conf
cat ./conf/pg.conf >> ${POSTGRESDBDIR}/postgresql.conf
mkdir -p /var/run/postgresql/postgres-main.pg_stat_tmp

# stats configuration
cp ${POSTGRESDBDIR}/postgresql.conf $POSTGRES_PERF_CONF
cat ./conf/stats.conf >> $POSTGRES_PERF_CONF

# wal-e configuration
cp ${POSTGRESDBDIR}/postgresql.conf $POSTGRES_WALE_CONF
cat ./conf/wale.conf >> $POSTGRES_WALE_CONF

# HSTORE
./hstore.sh

