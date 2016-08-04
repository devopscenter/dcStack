#!/bin/bash -ex

PGVERSION=$1
DATABASE=$2
VPC_CIDR=$3


. ./postgresenv.sh $PGVERSION

"${POSTGRESBINDIR}"/initdb -D "${POSTGRESDBDIR}" --locale=en_US.UTF-8

cat ./conf/hba.conf >> "${POSTGRESDBDIR}"/pg_hba.conf

# if VPC_CIDR passed in, then replace VPC_CIDR in pg_hba.conf and uncomment lines if necessary
if [[ -n "${VPC_CIDR}" ]]; then
  VPC_CIDR_ESCAPED=$(echo ${VPC_CIDR}|awk -F/ '{print $1 "\\""/" $2}')
  sed -i "s/<VPC_CIDR>/${VPC_CIDR_ESCAPED}/g" "${POSTGRESDBDIR}"/pg_hba.conf
  sed -i "s/\(#\)\(.*${VPC_CIDR_ESCAPED}.*\)/\2/g" "${POSTGRESDBDIR}"/pg_hba.conf
fi

# if passed in DATABASE then replace VPC_CIDR in pg_hba.conf and uncomment lines if necessary
if [[ -n "${DATABASE}" ]]; then
  sed -i "s/<DATABASE>/${DATABASE}/g" "${POSTGRESDBDIR}"/pg_hba.conf
  sed -i "s/\(#\)\(.*${DATABASE}.*\)/\2/g" "${POSTGRESDBDIR}"/pg_hba.conf
fi

cat ./conf/pg.conf >> "${POSTGRESDBDIR}"/postgresql.conf
mkdir -p /var/run/postgresql/postgres-main.pg_stat_tmp

# stats configuration
cp "${POSTGRESDBDIR}"/postgresql.conf "$POSTGRES_PERF_CONF"
cat ./conf/stats.conf >> "$POSTGRES_PERF_CONF"

# wal-e configuration
cp "${POSTGRESDBDIR}"/postgresql.conf "$POSTGRES_WALE_CONF"
cat ./conf/wale.conf >> "$POSTGRES_WALE_CONF"

# HSTORE
./hstore.sh $POSTGRES_VERSION

