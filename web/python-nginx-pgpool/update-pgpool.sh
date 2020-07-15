#!/usr/bin/env bash
#===============================================================================
#
#          FILE: update-pgpool.sh
#
#         USAGE: ./update-pgpool.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#         AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 07/27/2017 15:10:39
#      REVISION:  ---
#
# Copyright 2014-2020 devops.center llc
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

set -o nounset     # Treat unset variables as an error
set -o errexit      # exit immediately if command exits with a non-zero status
set -x              # essentially debug mode 

. ./pgpoolenv.sh

# either pass in the PGPOOL_VERSION or pick up the current default.

 PGPOOL_VERSION=${1:-${PGPOOL_VERSION}}


#-------------------------------------------------------------------------------
# put the build down in /installs...there was one there when the instance was 
# created so it should still be there.
#-------------------------------------------------------------------------------
sudo mkdir -p /installs
pushd /installs

#-------------------------------------------------------------------------------
# get the tarball that has the specified PGPOOL_VERSION number
#-------------------------------------------------------------------------------
sudo wget --quiet http://www.pgpool.net/download.php?f=pgpool-II-$PGPOOL_VERSION.tar.gz -O pgpool-II-$PGPOOL_VERSION.tar.gz

#-------------------------------------------------------------------------------
# untar it and move to that directory
#-------------------------------------------------------------------------------
sudo tar -xvf pgpool-II-$PGPOOL_VERSION.tar.gz && \
pushd pgpool-II-$PGPOOL_VERSION 

#-------------------------------------------------------------------------------
# and build it
#-------------------------------------------------------------------------------
sudo ./configure && sudo make --silent && sudo make --silent install

#-------------------------------------------------------------------------------
# all done so pop back out to where this started
#-------------------------------------------------------------------------------
popd 
popd

