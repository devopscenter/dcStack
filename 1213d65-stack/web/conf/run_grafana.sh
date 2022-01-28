#!/usr/bin/env bash
#===============================================================================
#
#          FILE: run_grafana.sh
#
#         USAGE: ./run_grafana.sh
#
#   DESCRIPTION: start script for running grafana
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Bob Lozano - bob@devops.center
#                Gregg Jensen - gjensen@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 08/31/2018 14:22:37
#      REVISION:  ---
#
# Copyright 2014-2018 devops.center llc
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
#
#===============================================================================

#set -o nounset     # Treat unset variables as an error
#set -o errexit     # exit immediately if command exits with a non-zero status
#set -o verbose     # print the shell lines as they are executed
#set -x             # essentially debug mode


#NAME=grafana-server
#DESC="Grafana Server"
#DEFAULT=/etc/default/$NAME
#
#GRAFANA_USER=grafana
#GRAFANA_GROUP=grafana
#GRAFANA_HOME=/usr/share/grafana
#CONF_DIR=/etc/grafana
#WORK_DIR=$GRAFANA_HOME
#DATA_DIR=/var/lib/grafana
#LOG_DIR=/var/log/grafana
#CONF_FILE=$CONF_DIR/grafana.ini
#MAX_OPEN_FILES=10000
#PID_FILE=/var/run/$NAME.pid
#DAEMON=/usr/sbin/$NAME

if [ -n "$MAX_OPEN_FILES" ]; then
	ulimit -n $MAX_OPEN_FILES
fi

# before we start need to make sure that pgmaster-1 is up and running and we need to create the
# grafana database inside postresql
if  ! $(psql -U postgres -l | grep '^ grafana\b' > /dev/null)  ; then
	psql -U postgres -c "create database grafana";
fi

# Prepare environment
#mkdir -p "$LOG_DIR" "$DATA_DIR" && chown "$GRAFANA_USER":"$GRAFANA_GROUP" "$LOG_DIR" "$DATA_DIR"
#touch "$PID_FILE" && chown "$GRAFANA_USER":"$GRAFANA_GROUP" "$PID_FILE"

#${DAEMON} --pidfile=${PID_FILE} --config=${CONF_FILE} --homepath=${GRAFANA_HOME} cfg:default.paths.data=${DATA_DIR} cfg:default.paths.logs=${LOG_DIR}

# start grafana
exec /opt/grafana/bin/grafana-server web