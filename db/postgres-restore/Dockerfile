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
FROM devopscenter/db_postgres-repmgr:v1.0
MAINTAINER josh < josh [at] devops {dot} center>

USER root

ENV POSTGRES_VERSION 9.3

RUN sudo apt-fast -y -q install postgresql-${POSTGRES_VERSION} postgresql-client-${POSTGRES_VERSION} postgresql-contrib-${POSTGRES_VERSION} postgresql-server-dev-${POSTGRES_VERSION} libpq5 libpq-dev

ENV POSTGRES_VERSION 9.4
USER postgres

RUN /usr/lib/postgresql/9.3/bin/initdb --locale en_US.UTF-8 -D /tmp/postgres/9.3
RUN /usr/lib/postgresql/9.4/bin/initdb --locale en_US.UTF-8 -D /tmp/postgres/9.4

RUN cp /etc/postgresql/9.3/main/postgresql.conf /tmp/postgres/9.3
RUN echo "data_directory = '/tmp/postgres/9.3'"  >> /tmp/postgres/9.3/postgresql.conf
RUN chmod -R 0700 /tmp/postgres/9.3

RUN cp /etc/postgresql/9.4/main/postgresql.conf /tmp/postgres/9.4
RUN echo "data_directory = '/tmp/postgres/9.4'"  >> /tmp/postgres/9.4/postgresql.conf
RUN chmod -R 0700 /tmp/postgres/9.4

#######

USER root

ONBUILD ADD wale.properties /scripts/wale.properties

RUN chown -R root:postgres /etc/wal-e.d

RUN chown -R postgres:postgres /tmp/postgres

USER postgres

ENV DATA_DIR /tmp/postgres/restore9.3
#ENV DATA_DIR /var/lib/postgresql/9.3/main

RUN source /scripts/wale.properties && wal-e backup-fetch $DATA_DIR LATEST
RUN rm -rf $DATA_DIR/backup_label

RUN cp /etc/postgresql/9.3/main/postgresql.conf $DATA_DIR/postgresql.conf
RUN echo "data_directory = '/tmp/postgres/restore9.3'"  >> /tmp/postgres/restore9.3/postgresql.conf
RUN chmod -R 0700 $DATA_DIR

RUN mkdir -p /var/run/postgresql/9.3-main.pg_stat_tmp
RUN /usr/lib/postgresql/9.3/bin/postgres -D $DATA_DIR -c config_file=$DATA_DIR/postgresql.conf || true
RUN /usr/lib/postgresql/9.3/bin/pg_resetxlog -f $DATA_DIR

RUN cp /etc/postgresql/9.4/main/postgresql.conf /var/lib/postgresql/9.4/main/postgresql.conf

ADD upgrade.sh /scripts/upgrade.sh
