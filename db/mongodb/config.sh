#!/usr/bin/env bash
#===============================================================================
#
#          FILE: config.sh
#
#         USAGE: config.sh
#
#   DESCRIPTION: setup mongodb
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 11/21/2016 15:13:37
#      REVISION:  ---
#
# Copyright 2014-2017 devops.center llc
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
set -o errexit      # exit immediately if command exits with a non-zero status
set -x             # essentially debug mode

MONBODBVERSION=$1
DATABASE=$2
VPC_CIDR=$3

. ./mongodbenv.sh $MONBODBVERSION

#"${MONGODBBINDIR}"/initdb -D "${MONGODBDBDIR}" --locale=en_US.UTF-8
#
#cat ./conf/hba.conf >> "${MONGODBDBDIR}"/pg_hba.conf
#
## if VPC_CIDR passed in, then replace VPC_CIDR in pg_hba.conf and uncomment lines if necessary
#if [[ -n "${VPC_CIDR}" ]]; then
#  VPC_CIDR_ESCAPED=$(echo ${VPC_CIDR}|awk -F/ '{print $1 "\\""/" $2}')
#  sed -i "s/<VPC_CIDR>/${VPC_CIDR_ESCAPED}/g" "${MONGODBDBDIR}"/pg_hba.conf
#  sed -i "s/\(#\)\(.*${VPC_CIDR_ESCAPED}.*\)/\2/g" "${MONGODBDBDIR}"/pg_hba.conf
#fi
#
## if passed in DATABASE then replace VPC_CIDR in pg_hba.conf and uncomment lines if necessary
#if [[ -n "${DATABASE}" ]]; then
#  sed -i "s/<DATABASE>/${DATABASE}/g" "${MONGODBDBDIR}"/pg_hba.conf
#  sed -i "s/\(#\)\(.*${DATABASE}.*\)/\2/g" "${MONGODBDBDIR}"/pg_hba.conf
#fi
#
#cat ./conf/pg.conf >> "${MONGODBDBDIR}"/mongodbql.conf
#mkdir -p /var/run/mongodbql/mongodb-main.pg_stat_tmp
#
## stats configuration
#cp "${MONGODBDBDIR}"/mongodbql.conf "$MONGODB_PERF_CONF"
#cat ./conf/stats.conf >> "$MONGODB_PERF_CONF"
#
## wal-e configuration
#cp "${MONGODBDBDIR}"/mongodbql.conf "$MONGODB_WALE_CONF"
#cat ./conf/wale.conf >> "$MONGODB_WALE_CONF"
#
## HSTORE
#./hstore.sh ${MONGODB_VERSION}
#
