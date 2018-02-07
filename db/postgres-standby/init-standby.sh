#!/usr/bin/env bash
#===============================================================================
#
#          FILE: init-standby.sh
# 
#         USAGE: ./init-standby.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 04/24/2017 16:50:58
#      REVISION:  ---
#
# Copyright 2014 devops.center
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#===============================================================================

#set -o nounset         # Treat unset variables as an error
#set -x                  # essentially debug mode
set -o errexit          # exit immediately if command exists with a non-zero status

#-------------------------------------------------------------------------------
# grab the functions to pretty up the logging
#-------------------------------------------------------------------------------
source  /usr/local/bin/dcEnv.sh

dcStartLog "initialize database follower/standby"

#-------------------------------------------------------------------------------
dcLog "First stop postgres"
#-------------------------------------------------------------------------------
sudo supervisorctl stop postgres


#-------------------------------------------------------------------------------
dcLog "now remove the xlog files"
#-------------------------------------------------------------------------------
#sudo unlink /media/data/postgres/db/pgdata/pg_xlog
sudo rm -rf /media/data/postgres/db/pgdata/pg_xlog
sudo rm -rf /media/data/postgres/db/pgdata/ /media/data/postgres/db/pg_xlog/ /media/data/postgres/xlog/*

#ln -s /media/data/postgres/xlog /media/data/postgres/db/pg_xlog
#sudo chown -R postgres:postgres /media/data/postgres/xlog

#-------------------------------------------------------------------------------
dcLog "start the base backup on pgmaster-1 and set up a stream back to this machine"
#-------------------------------------------------------------------------------
sudo pg_basebackup -D /media/data/postgres/db/pgdata -w -R --xlog-method=stream --dbname="host=pgmaster-1 user=postgres"


#-------------------------------------------------------------------------------
dcLog "while the backup is streaming from pgmaster-1, copy the xlog entries back to this machine"
#-------------------------------------------------------------------------------
sudo rsync -av /media/data/postgres/db/pgdata/pg_xlog/ /media/data/postgres/xlog
sudo rm -rf /media/data/postgres/db/pgdata/pg_xlog
sudo ln -s /media/data/postgres/xlog/ /media/data/postgres/db/pgdata/pg_xlog
sudo chown -R postgres:postgres /media/data/postgres/db /media/data/postgres/xlog

#-------------------------------------------------------------------------------
dcLog "replace master's conf file so wal-e backups go to the correct bucket if promoted"
#-------------------------------------------------------------------------------
# actually grab the archive command from the original postgresql.conf and add it 
# to new postgresql.conf
#sudo cp --preserve /media/data/postgres/backup/postgresql.conf /media/data/postgres/db/pgdata/
archiveCommand=$(grep "^archive_command" /media/data/postgres/backup/postgresql.conf)
sudo sed -i "s/^archive_command/#archive_command/" /media/data/postgres/db/pgdata/postgresql.conf
echo ${archiveCommand} | sudo tee -a /media/data/postgres/db/pgdata/postgresql.conf

#-------------------------------------------------------------------------------
dcLog "and finally start postgres"
#-------------------------------------------------------------------------------
sudo supervisorctl start postgres
dcEndLog "Finished..."
