#!/bin/bash -e

sudo rsync -av /media/data/postgres/db/pg_xlog/ /media/data/postgres/xlog/
sudo rm -rf /media/data/postgres/db/pg_xlog
sudo ln -s /media/data/postgres/xlog /media/data/postgres/db/pg_xlog
sudo chown -R postgres:postgres /media/data/postgres/xlog

