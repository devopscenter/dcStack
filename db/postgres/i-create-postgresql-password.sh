#!/bin/bash - 
#===============================================================================
#
#          FILE: i-create-postgresql-password.sh
# 
#         USAGE: ./i-create-postgresql-password.sh 
# 
#   DESCRIPTION: script to create the postgres password and echo the results
#                at the end so the calling script can catch the value
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 04/10/2017 15:46:05
#      REVISION:  ---
#===============================================================================

#set -o nounset        # Treat unset variables as an error
set -x                # essentially debug mode

PUBLIC_IP=$1
CUST_APP_NAME=$2
#-------------------------------------------------------------------------------
# set postgres user password
#-------------------------------------------------------------------------------
PG_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
psql -U postgres -c "ALTER USER Postgres WITH PASSWORD '${PG_PWD}' ;"
echo "postgres user password: ${PG_PWD}"
echo "To be used to access the database using the public IP:"
echo "postgres://postgres:${PG_PWD}@${PUBLIC_IP}/${CUST_APP_NAME,,}"
