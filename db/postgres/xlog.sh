#!/bin/bash -e

PGVERSION=$1
. ./postgresenv.sh $PGVERSION


sudo rsync -av ${POSTGRESDBDIR}/pg_xlog/ ${POSTGREX_XLOG}/
sudo rm -rf ${POSTGRESDBDIR}/pg_xlog
sudo ln -s ${POSTGREX_XLOG} ${POSTGRESDBDIR}/pg_xlog
sudo chown -R postgres:postgres ${POSTGREX_XLOG}

