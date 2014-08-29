FROM ubuntu:trusty
MAINTAINER josh < josh [at] devops {dot} center>

ENV IS_DOCKER True

RUN apt-get update && apt-get -y install python-software-properties software-properties-common
RUN add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN apt-get update

RUN add-apt-repository ppa:saiarcot895/myppa
RUN apt-get update
RUN apt-get -y install apt-fast

ENV GIT_VERSION 1:2.1.0-1~ppa0~ubuntu14.04.1
ENV PYTHON_VERSION 2.7.8

RUN add-apt-repository ppa:git-core/ppa
RUN apt-fast update
#RUN apt-cache showpkg git python-dev apache2 libapache2-mod-wsgi python-pip curl
RUN apt-fast -y install git=$GIT_VERSION

RUN apt-fast -y install wget sudo vim curl
RUN apt-fast -y install build-essential

RUN apt-fast -y install sqlite3 libsqlite3-dev libssl-dev zlib1g-dev libxml2-dev libbz2-dev
ADD https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz /tmp/Python-${PYTHON_VERSION}.tgz
RUN cd /tmp && tar -xvf Python-${PYTHON_VERSION}.tgz
RUN cd /tmp/Python-${PYTHON_VERSION} \
    && ./configure CFLAGSFORSHARED="-fPIC" CCSHARED="-fPIC" --quiet CCSHARED="-fPIC" --prefix=/usr/local/opt/python --exec-prefix=/usr/local/opt/python CCSHARED="-fPIC" \
    && make clean && make -j3 && make install

ENV PATH /usr/local/opt/python/bin:$PATH

#RUN ln -s /usr/local/bin/python2.7 /usr/local/bin/python
RUN which python && python --version

RUN cd /tmp && wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

RUN pip install distribute==0.6.49 && pip install -U setuptools && pip install -U pip

RUN pip install virtualenv==1.11.6
