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
ENV PYTHONPIP_VERSION 1.5.4
ENV APACHE_VERSION 2.4.7-1ubuntu4.1
ENV MODWSGI_VERSION 3.4-4ubuntu2.1.14.04.1
ENV PYTHON_VERSION 2.7.8
ENV PYTHONPIP_VERSION 1.5.4
ENV POSTGRES_VERSION 9.3

RUN add-apt-repository ppa:git-core/ppa
RUN apt-fast update
#RUN apt-cache showpkg git python-dev apache2 libapache2-mod-wsgi python-pip curl
RUN apt-fast -y install git=$GIT_VERSION

RUN apt-fast -y install wget sudo vim curl
RUN apt-fast -y install build-essential

RUN apt-fast -y install sqlite3 libsqlite3-dev libssl-dev zlib1g-dev libxml2-dev libbz2-dev
ADD https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz /tmp/Python-2.7.8.tgz
RUN cd /tmp && tar -xvf Python-2.7.8.tgz
RUN cd /tmp/Python-2.7.8 && ./configure --quiet && make -j3 && make altinstall

RUN ln -s /usr/local/bin/python2.7 /usr/local/bin/python


RUN cd /tmp && wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

RUN pip install distribute==0.6.49 && pip install -U setuptools && pip install -U pip

RUN pip install virtualenv==1.11.6
