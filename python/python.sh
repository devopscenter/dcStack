#!/usr/bin/env bash
#===============================================================================
#
#          FILE: python.sh
#
#         USAGE: python.sh
#
#   DESCRIPTION: install python and other utilities that python uses.
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
set -o verbose

echo "============================ Building element: python ===================="
echo "PATH=/usr/local/opt/python/bin:$PATH" | sudo tee -a /etc/environment

sudo apt-get -qq update && apt-get -qq -y install python-software-properties software-properties-common && \
    sudo add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
    sudo apt-get -qq update

sudo add-apt-repository -y ppa:saiarcot895/myppa && \
    sudo apt-get -qq update && \
    sudo apt-get -qq -y install apt-fast

export GIT_VERSION=2.17.0
export PYTHON_VERSION=2.7.15

sudo apt-fast -qq update
sudo apt-fast -qq -y install wget sudo vim curl build-essential

sudo apt-fast -qq -y install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev libffi-dev python-dev
pushd /tmp
sudo wget --quiet https://www.kernel.org/pub/software/scm/git/git-2.17.0.tar.gz
sudo tar -xvf git-2.17.0.tar.gz
pushd git-2.17.0
sudo make --silent prefix=/usr/local all && sudo make --silent prefix=/usr/local install
popd
popd

sudo apt-fast -qq -y install sqlite3 libsqlite3-dev libssl-dev zlib1g-dev libxml2-dev libxslt-dev libbz2-dev gfortran libopenblas-dev liblapack-dev libatlas-dev subversion

pushd /tmp
sudo wget --quiet https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz -O /tmp/Python-${PYTHON_VERSION}.tgz
sudo tar -xvf Python-${PYTHON_VERSION}.tgz
pushd Python-${PYTHON_VERSION}
sudo ./configure CFLAGSFORSHARED="-fPIC" CCSHARED="-fPIC" --quiet CCSHARED="-fPIC" --prefix=/usr/local/opt/python --exec-prefix=/usr/local/opt/python CCSHARED="-fPIC" \
            && make clean && make --silent -j3 && sudo make --silent install
popd

sudo ln -s /usr/local/opt/python/bin/python /usr/local/bin/python

which python && python --version

pushd /tmp
sudo wget --quiet https://bootstrap.pypa.io/get-pip.py && sudo python get-pip.py
sudo ln -s /usr/local/opt/python/bin/pip /usr/local/bin/pip

sudo pip install -U setuptools-git wheel virtualenv

sudo mkdir -p /wheelhouse

#ipython
sudo apt-fast -qq -y install libncurses5-dev
sudo pip install readline==6.2.4.1

# Create a scratch directory, if it doesn't already exist
if [[ ! -e /data/scratch ]]; then
    sudo mkdir -p /data/scratch
    sudo chmod -R 777 /data/scratch
fi
echo "============================ Finished element: python ===================="
