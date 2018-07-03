#!/usr/bin/env bash
#===============================================================================
#
#          FILE: i-deploy_webandworker.sh
#
#         USAGE: ./i-deploy_webandworker.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#                PRIVATE_IP=$1
#                STACK=$3
#                SUFFIX=$4
#                ENV=$5
#                PGVERSION=$6
#          BUGS: ---
#         NOTES: ---
#        AUTHOR2: Gregg Jensen (), gjensen@devops.center
#                 Bob Lozano (), bob@devops.center
#        AUTHOR2: Josh & Trey
#  ORGANIZATION: devops.center
#       CREATED: 09/29/2016 09:23:15
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
#set -o errexit      # exit immediately if command exits with a non-zero status
set -x             # essentially debug mode

# All 6 arguments are required

PRIVATE_IP=$1
STACK=$2
SUFFIX=$3
ENV=$4
PGVERSION=$5
CUST_APP_NAME=$6
COMBINED_WEB_WORKER=${7}
SCRATCHVOLUME=${8-"false"}

if  [[ -z ${PRIVATE_IP} ]] ||
    [[ -z ${STACK} ]] ||
    [[ -z ${SUFFIX} ]] ||
    [[ -z ${ENV} ]] ||
    [[ -z ${CUST_APP_NAME} ]] ||
    [[ -z ${PGVERSION} ]] ; then

    echo "6 Arguments are required: "
    echo "    PRIVATE_IP: ${PRIVATE_IP}"
    echo "    STACK: ${STACK}"
    echo "    SUFFIX: ${SUFFIX}"
    echo "    ENV: ${ENV}"
    echo "    PGVERSION: ${PGVERSION}"
    echo "    CUST_APP_NAME: ${CUST_APP_NAME}"
    exit 1
fi

#
# All web and worker instances use /data for code deploys, some for other stuff
#
sudo mkdir /data 

#-------------------------------------------------------------------------------
# If this will have an attached scratch volume, then prepare and mount it,
# then make sure that code deploys go onto the scratch volume as well.
#-------------------------------------------------------------------------------
if [[ ${SCRATCHVOLUME} == "true" ]]; then
    pushd ~/dcStack/db/postgres/
    sudo ./i-mount.sh "/media/data"

    sudo mkdir /media/data/deploy
    sudo ln -s /media/data/deploy /data/deploy 
    popd
else
    sudo mkdir -p /data/deploy
fi

# Create standard temp directory, then set up a symlink
# to a previous standard, for compatibility reasons
# Also create a standard directory for db restores.
sudo mkdir -p /media/data/tmp
sudo chmod 777 /media/data/tmp
sudo ln -s /media/data/tmp /data/scratch

sudo mkdir -p /media/data/db_restore
sudo chmod 777 /media/data/db_restore

#-------------------------------------------------------------------------------
# install standard packages/utilities
#-------------------------------------------------------------------------------
cd ~/dcStack/buildtools/utils/ || exit
sudo ./base-utils.sh

#-------------------------------------------------------------------------------
# install stack common to web and workers
#-------------------------------------------------------------------------------
cd ~/dcStack/python/ || exit
sudo ./python.sh

cd ~/dcStack/buildtools/utils || exit
sudo ./install-supervisor.sh custom

#-------------------------------------------------------------------------------
# Fix configuration files, using env vars distributed in the customer-specific (and private) utils.
#-------------------------------------------------------------------------------
if [[ (-n "${ENV}") && (-e "${HOME}/${CUST_APP_NAME}/${CUST_APP_NAME}-utils/environments/${ENV}.env") ]]; then
    pushd ~/dcUtils/
    ./deployenv.sh --type instance --env $ENV --appName ${CUST_APP_NAME}
    popd
fi

#-------------------------------------------------------------------------------
# enable logging
#-------------------------------------------------------------------------------
cd ~/dcStack/logging/ || exit
./i-enable-logging.sh

#-------------------------------------------------------------------------------
#  install nginx
#-------------------------------------------------------------------------------
cd ~/dcStack/web/python-nginx/ || exit
sudo ./nginx.sh

#-------------------------------------------------------------------------------
# install pgpool
#-------------------------------------------------------------------------------
cd ~/dcStack/web/python-nginx-pgpool/ || exit
sudo ./pgpool.sh "$PGVERSION"

#-------------------------------------------------------------------------------
# install redis client
#-------------------------------------------------------------------------------
cd ~/dcStack/web/python-nginx-pgpool-redis/ || exit
sudo ./redis-client-install.sh

#-------------------------------------------------------------------------------
# Install customer-specific stack - all (both web and worker) get the web portion.
#-------------------------------------------------------------------------------
if [[ -d ~/dcStack/${STACK}-stack/web ]]; then
    cd ~/dcStack/${STACK}-stack/web/ 
    if [[ -f ./web.sh ]]; then
        sudo ./web.sh ${SCRATCHVOLUME} 
    fi
fi

#-------------------------------------------------------------------------------
# Before running the application specific commands we need to create a directory
# that is similar to the setup in a docker container so that the {web|worker}-commands.sh
# can reference the same directory structure
#-------------------------------------------------------------------------------
STANDARD_APP_UTILS_DIR="/app-utils/conf"
if [[ ! -d "${STANDARD_APP_UTILS_DIR}" ]]; then
    sudo mkdir "/app-utils"
    # we will do a symbolic link since that is the most efficient
fi

sudo ln -s "${HOME}/${CUST_APP_NAME}/${CUST_APP_NAME}-utils/config/${ENV}" "${STANDARD_APP_UTILS_DIR}"

#-------------------------------------------------------------------------------
# run the appliction specific web_commands.sh 
#-------------------------------------------------------------------------------
if [[ -e "${STANDARD_APP_UTILS_DIR}/web-commands.sh" ]]; then
    cd ${STANDARD_APP_UTILS_DIR}
    sudo ./web-commands.sh
fi

# If there is a worker specific install, then invoke it.
if [[ "${SUFFIX}" == "worker" || "${COMBINED_WEB_WORKER}" == "true" ]]; then
    # first do the stack specific worker.sh script
    if [[ -f "${HOME}/dcStack/${STACK}-stack/worker/worker.sh" ]]; then
        cd ${HOME}/dcStack/${STACK}-stack/worker
        sudo ./worker.sh ${COMBINED_WEB_WORKER} ${SCRATCHVOLUME} 
    fi

    # and now  do the stack specific worker.sh script
    if [[ -f "${STANDARD_APP_UTILS_DIR}/worker-commands.sh" ]]; then
        cd ${STANDARD_APP_UTILS_DIR}
        sudo ./worker-commands.sh ${COMBINED_WEB_WORKER}
    fi
fi

set +x

#-------------------------------------------------------------------------------
# Restart supervisor, so that all services are now running.
#-------------------------------------------------------------------------------
if !(sudo /etc/init.d/supervisor restart); then
    echo "Error somewhere in supervisor or one of the services started by supervisor"
fi
