#!/bin/bash -evx

PGVERSION=$1
. ./postgresenv.sh $PGVERSION

# Setup supervisor to run postgres
sudo cp ./conf/supervisor-postgres.conf /etc/supervisor/conf.d/postgres.conf
sudo cp ./conf/run_postgres.sh /etc/supervisor/conf.d/run_postgres.sh
echo "export POSTGRES_VERSION=${POSTGRES_VERSION}"  | sudo tee -a /etc/default/supervisor

# If on an instance, drop a .env file so that this will always be set when ENVs are updated at any point in the future.
if [[ -d "$HOME/.dcConfig/" ]] ; then echo "POSTGRES_VERSION=${POSTGRES_VERSION}" >> "$HOME/.dcConfig/instance-postgres.env"