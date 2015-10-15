#!/bin/bash -e

. ./postgresenv.sh

sudo rsync -av /media/data/postgres/db/pgdata/pg_xlog/ /media/data/postgres/xlog/transactions/
sudo rm -rf /media/data/postgres/db/pgdata/pg_xlog
sudo ln -s /media/data/postgres/xlog/transactions /media/data/postgres/db/pgdata/pg_xlog
sudo chown -R postgres:postgres /media/data/postgres/xlog/transactions

