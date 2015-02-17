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

FROM devopscenter/python-apache:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

ENV POSTGRES_VERSION 9.4

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.4``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN sudo apt-fast update

RUN sudo apt-fast -y -q install postgresql-client-$POSTGRES_VERSION libpq5 libpq-dev
#        postgresql-contrib-$POSTGRES_VERSION postgresql-server-dev-$POSTGRES_VERSION

#not installing postgres server, so manually create user
RUN useradd postgres -m -s /bin/bash
#RUN groupadd postgres
RUN usermod -a -G postgres postgres

RUN mkdir /installs
ENV PGPOOL_VERSION 3.4.1
RUN cd /installs && wget http://www.pgpool.net/download.php?f=pgpool-II-$PGPOOL_VERSION.tar.gz -O pgpool-II-$PGPOOL_VERSION.tar.gz && \
cd /installs && tar -xvf pgpool-II-$PGPOOL_VERSION.tar.gz && \
cd /installs/pgpool-II-$PGPOOL_VERSION && ./configure && make && make install

RUN mkdir -p -m 700 /etc/pgpool2 && chown -R postgres:postgres /etc/pgpool2 && \
mkdir -p -m 755 /var/log/pgpool && chown -R postgres:postgres /var/log/pgpool
ADD pgpool/pgpool2.init.d /etc/init.d/pgpool
RUN chmod 755 /etc/init.d/pgpool
#USER postgres
ADD pgpool/pool_hba.conf /etc/pgpool2/pool_hba.conf
ADD pgpool/pgpool.conf.one /etc/pgpool2/pgpool.conf.one
ADD pgpool/pgpool.conf.two /etc/pgpool2/pgpool.conf.two
ADD pgpool/pgpool.conf.three /etc/pgpool2/pgpool.conf.three
ADD pgpool/pcp.conf /etc/pgpool2/pcp.conf
RUN chown -R postgres:postgres /etc/pgpool2 && \
mkdir -p /var/run/pgpool && \
chown -R postgres:postgres /var/run/pgpool && \
mkdir -p /var/run/postgresql/ && \
chown -R postgres:postgres  /var/run/postgresql/

#Fix locale warnings when starting postgres
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

ADD pgpool.conf /etc/supervisor/conf.d/pgpool.conf

CMD /bin/bash -c "rm -rf /var/run/pgpool/pgpool.pid && rm -rf /var/run/postgresql/.s.* && /usr/bin/supervisord && tail -f /dev/null"
