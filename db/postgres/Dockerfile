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

ENV POSTGRES_VERSION 9.4
ENV POSTGRESDBDIR /media/data/postgres/db
ENV POSTGRESBINDIR /usr/lib/postgresql/${POSTGRES_VERSION}/bin

ADD postgres.sh /installs/postgres.sh
WORKDIR /installs
RUN ./postgres.sh

USER postgres

RUN ${POSTGRESBINDIR}/initdb -D ${POSTGRESDBDIR}

# Adjust PostgreSQL configuration so that remote connections to the data are possible.
ADD pg_hba.conf ${POSTGRESDBDIR}/pg_hba.conf
RUN chown postgres:postgres ${POSTGRESDBDIR}/pg_hba.conf

ADD conf /installs/conf

RUN cat /installs/conf/hba.conf >> ${POSTGRESDBDIR}/pg_hba.conf

RUN cat /installs/conf/pg.conf >> ${POSTGRESDBDIR}/postgresql.conf

RUN mkdir -p /var/run/postgresql/9.4-main.pg_stat_tmp

# stats configuration
ENV POSTGRES_CONF ${POSTGRESDBDIR}/postgresql.conf
ENV POSTGRES_PERF_CONF ${POSTGRESDBDIR}/postgresql.conf.perf
RUN cp ${POSTGRESDBDIR}/postgresql.conf $POSTGRES_PERF_CONF
RUN cat /installs/conf/stats.conf >> $POSTGRES_PERF_CONF

# wal-e configuration
ENV POSTGRES_WALE_CONF ${POSTGRESDBDIR}/postgresql.conf.wale
RUN cp ${POSTGRESDBDIR}/postgresql.conf $POSTGRES_WALE_CONF
RUN cat /installs/conf/wale.conf >> $POSTGRES_WALE_CONF

# HSTORE
ADD hstore.sh /installs/hstore.sh
RUN ./hstore.sh

USER root
RUN chown -R postgres:postgres /var/lib/postgresql 
ADD rsyslogd.conf /etc/supervisor/conf.d/rsyslogd.conf
ADD postgres.conf /etc/supervisor/conf.d/postgres.conf


# Set the default command to run when starting the container
CMD /bin/bash -c "/usr/bin/supervisord && tail -f /dev/null"


# Add VOLUMEs to allow backup of config, logs and datas
VOLUME  ["/media/data/postgres/db"]

EXPOSE 5432
