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
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 07/27/2017 15:10:39
#      REVISION:  ---
#===============================================================================

#set -o nounset      # Treat unset variables as an error
set -x              # essentially debug mode 

# they have to pass in the PGPOOL_VERSION that pgpool will be updated to.
if [[ -n "$1" ]]; then
  PGPOOL_VERSION=$1
else
    echo "You need to provide the pgpool version number to update to."
    exit 1
fi

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

