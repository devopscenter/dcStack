#!/bin/bash -e

sudo apt-get update && apt-get -y install python-software-properties software-properties-common && \
    sudo add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
    sudo apt-get update

sudo add-apt-repository ppa:saiarcot895/myppa && \
    sudo apt-get update && \
    sudo apt-get -y install apt-fast

export GIT_VERSION=2.1.2
export PYTHON_VERSION=2.7.10

sudo apt-fast update
sudo apt-fast -y install wget sudo vim curl build-essential

sudo apt-fast -y install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
pushd /tmp
wget https://www.kernel.org/pub/software/scm/git/git-2.1.2.tar.gz
tar -xvf git-2.1.2.tar.gz
pushd git-2.1.2 
make prefix=/usr/local all && sudo make prefix=/usr/local install
popd
popd

sudo apt-fast -y install sqlite3 libsqlite3-dev libssl-dev zlib1g-dev libxml2-dev libxslt-dev libbz2-dev gfortran libopenblas-dev liblapack-dev libatlas-dev subversion
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz /tmp/Python-${PYTHON_VERSION}.tgz
pushd /tmp
tar -xvf Python-${PYTHON_VERSION}.tgz
./configure CFLAGSFORSHARED="-fPIC" CCSHARED="-fPIC" --quiet CCSHARED="-fPIC" --prefix=/usr/local/opt/python --exec-prefix=/usr/local/opt/python CCSHARED="-fPIC" \
            && make clean && make -j3 && sudo make install

sudo ln -s /usr/local/opt/python/bin/python /usr/local/bin/python

which python && python --version

pushd /tmp
wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py 
sudo ln -s /usr/local/opt/python/bin/pip /usr/local/bin/pip

sudo pip install -U setuptools-git==1.1 wheel==0.24.0 virtualenv==1.11.6 
sudo pip install -U pip==7.1.0
#RUN pip install -U distribute==0.7.3  setuptools==8.3

sudo mkdir -p /wheelhouse

#ipython
sudo apt-fast -y install libncurses5-dev
sudo pip install readline==6.2.4.1

sudo mkdir -p /data/scratch && \
    chmod -R 777 /data/scratch
