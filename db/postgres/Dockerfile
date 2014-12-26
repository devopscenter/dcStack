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

FROM ubuntu:trusty
MAINTAINER josh < josh [at] devops {dot} center>

ENV POSTGRES_VERSION 9.4

RUN apt-get update && apt-get -y install python-software-properties software-properties-common
RUN add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN apt-get update

RUN add-apt-repository ppa:saiarcot895/myppa
RUN apt-get update
RUN apt-get -y install apt-fast

RUN apt-fast -y install git python-dev python-pip wget sudo vim

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``${POSTGRES_VERSION}``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN sudo apt-fast update

RUN sudo apt-fast -y -q install postgresql-${POSTGRES_VERSION} postgresql-client-${POSTGRES_VERSION} postgresql-contrib-${POSTGRES_VERSION} postgresql-server-dev-${POSTGRES_VERSION} libpq5 libpq-dev

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible. 
ADD pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/9.4/main/pg_hba.conf

#Fix locale warnings when starting postgres
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

USER postgres

RUN echo "host all          all    0.0.0.0/0  trust" >> /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf
RUN echo "host replication  all    0.0.0.0/0  trust" >> /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf

# And add ``listen_addresses`` 
RUN echo "listen_addresses='*'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf

# ssl not needed for now. also gives error on boot2docker
RUN echo "ssl = false                              # (change requires restart)" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "wal_level = hot_standby          # minimal, archive, or hot_standby" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "hot_standby = on            # 'on' allows queries during recovery" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "max_wal_senders = 5      # max number of walsender processes" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.4/bin/postgres", "-D", "/var/lib/postgresql/9.4/main", "-c", "config_file=/etc/postgresql/9.4/main/postgresql.conf"]

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/var/lib/postgresql/9.4/main"]

EXPOSE 5432

USER root
RUN pip install --upgrade distribute
RUN pip install -U six
RUN pip install wal-e==0.7.3
RUN apt-fast install -y daemontools lzop pv

RUN umask u=rwx,g=rx,o=
#RUN mkdir -p /etc/wal-e.d/env/dev
#RUN mkdir -p /etc/wal-e.d/env/alpha
RUN mkdir -p /etc/wal-e.d/env/prod

RUN chown -R root:postgres /etc/wal-e.d

USER postgres

RUN mkdir -p /var/run/postgresql/9.4-main.pg_stat_tmp
