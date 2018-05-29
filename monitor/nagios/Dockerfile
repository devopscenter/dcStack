#
# Docker Stack - Docker stack to manage infrastructures
#
# Copyright 2015 devops.center
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

FROM jasonrivers/nagios
MAINTAINER josh < josh [at] devops {dot} center>

RUN apt-get -qq update && apt-get -qq -y install python-software-properties software-properties-common && \
add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe" && \
apt-get -qq update

RUN add-apt-repository -y ppa:saiarcot895/myppa && \
apt-get -qq update && \
apt-get -qq -y install apt-fast

RUN apt-get install sudo

ARG POSTGRES_VERSION
ENV POSTGRES_VERSION ${POSTGRES_VERSION}

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.4``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN sudo apt-fast -qq update

RUN sudo apt-fast -y -qq install postgresql-client-${POSTGRES_VERSION} libpq5 libpq-dev

#RUN sudo apt-fast -y install supervisor

ENV REDIS_VERSION 3.0.0
RUN cd / && wget http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz && \
cd / && tar xvzf redis-$REDIS_VERSION.tar.gz && \
cd /redis-$REDIS_VERSION && make --silent -j 3 && make --silent install

RUN mkdir /tmp/check_postgres
RUN cd /tmp/check_postgres && wget http://bucardo.org/downloads/check_postgres-2.21.0.tar.gz && tar -xvf check_postgres-2.21.0.tar.gz
RUN cd /tmp/check_postgres/check_postgres-2.21.0 && perl Makefile.PL && make --silent && make --silent install

RUN apt-fast -qq -y install python-dev
RUN cd /tmp && wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py
#RUN apt-fast install -y mysql-client libmysqlclient-dev mysql-server libsnappy-dev 
RUN apt-fast -qq install -y libsnappy-dev libmysqlclient-dev
RUN pip install MySQL-python==1.2.5

#for XMLParser
RUN sudo apt-fast -qq install -y expat libexpat1-dev
RUN cd /tmp && wget http://search.cpan.org/CPAN/authors/id/M/MS/MSERGEANT/XML-Parser-2.36.tar.gz && tar -xvf XML-Parser-2.36.tar.gz 
RUN cd /tmp/XML-Parser-2.36 && perl Makefile.PL && make --silent && make test && make --silent install

RUN sudo cpan JSON  && sudo cpan Term::ReadKey && sudo cpan Redis

RUN mkdir -p /usr/local/lib/nagios && cd /usr/local/lib/nagios && git clone https://github.com/harisekhon/nagios-plugins
RUN cd /usr/local/lib/nagios/nagios-plugins && make --silent

ENV PATH /usr/local/lib/nagios/nagios-plugins:$PATH
