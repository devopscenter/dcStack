#!/bin/bash

#First competely shut down and disconnect the master.
sudo supervisorctl stop postgres
sudo rm -f /etc/supervisor/conf.d/postgres.conf
sudo rm -f /etc/supervisor/conf.d/run_postgres.sh
sudo service supervisor restart
