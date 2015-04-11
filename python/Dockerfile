#
# Docker Stack - Docker stack to manage infrastructures
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
#

FROM baseimageversion
MAINTAINER josh < josh [at] devops {dot} center>

ENV IS_DOCKER True
ENV HOME /root

RUN apt-get update && apt-get -y install python-software-properties software-properties-common && \
add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
apt-get update

RUN add-apt-repository ppa:saiarcot895/myppa && \
apt-get update && \
apt-get -y install apt-fast

ENV GIT_VERSION     2.1.2
ENV PYTHON_VERSION  2.7.9

RUN apt-fast update
RUN apt-fast -y install wget sudo vim curl build-essential

RUN apt-fast -y install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
RUN cd /tmp && wget https://www.kernel.org/pub/software/scm/git/git-2.1.2.tar.gz
RUN cd /tmp && tar -xvf git-2.1.2.tar.gz
RUN cd /tmp/git-2.1.2 && make prefix=/usr/local all && make prefix=/usr/local install

RUN apt-fast -y install sqlite3 libsqlite3-dev libssl-dev zlib1g-dev libxml2-dev libbz2-dev gfortran libopenblas-dev liblapack-dev libatlas--dev subversion
ADD https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz /tmp/Python-${PYTHON_VERSION}.tgz
RUN cd /tmp && tar -xvf Python-${PYTHON_VERSION}.tgz
RUN cd /tmp/Python-${PYTHON_VERSION} \
    && ./configure CFLAGSFORSHARED="-fPIC" CCSHARED="-fPIC" --quiet CCSHARED="-fPIC" --prefix=/usr/local/opt/python --exec-prefix=/usr/local/opt/python CCSHARED="-fPIC" \
    && make clean && make -j3 && make install

ENV PATH /usr/local/opt/python/bin:$PATH
RUN ln -s /usr/local/opt/python/bin/python /usr/local/bin/python

#RUN ln -s /usr/local/bin/python2.7 /usr/local/bin/python
RUN which python && python --version

RUN cd /tmp && wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py 
RUN ln -s /usr/local/opt/python/bin/pip /usr/local/bin/pip

RUN pip install -U setuptools-git==1.1 wheel==0.24.0 virtualenv==1.11.6 
RUN pip install -U pip==6.1.1
#RUN pip install -U distribute==0.7.3  setuptools==8.3

RUN mkdir -p /wheelhouse

#ipython
RUN apt-fast -y install libncurses5-dev
RUN pip install readline==6.2.4.1

RUN mkdir -p /data/scratch && \
chmod -R 777 /data/scratch
