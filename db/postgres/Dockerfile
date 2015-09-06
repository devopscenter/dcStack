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

ADD postgres.sh /installs/postgres.sh
WORKDIR /installs
RUN ./postgres.sh

# Adjust PostgreSQL configuration so that remote connections to the data are possible. 
ADD pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/9.4/main/pg_hba.conf

USER postgres

cat hba.conf >> /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf

RUN cat pg.conf >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf

RUN mkdir -p /var/run/postgresql/9.4-main.pg_stat_tmp

# stats configuration
ENV POSTGRES_PERF_CONF /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf.perf
RUN cp /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf $POSTGRES_PERF_CONF
ADD stats.conf /installs/stats.conf
RUN cat /installs/stats.conf >> $POSTGRES_PERF_CONF

# wal-e configuration
ENV POSTGRES_WALE_CONF /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf.wale
RUN cp /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf $POSTGRES_WALE_CONF
ADD wale.conf /installs/wale.conf
RUN cat /installs/wale.conf >> $POSTGRES_WALE_CONF


# HSTORE
RUN echo "CREATE EXTENSION hstore;" | \
    /bin/bash -c "/usr/lib/postgresql/9.4/bin/postgres --single \
    -D /var/lib/postgresql/9.4/main \
    -c config_file=$POSTGRES_CONF \
    template1"

USER root
RUN chown -R postgres:postgres /var/lib/postgresql 
ADD rsyslogd.conf /etc/supervisor/conf.d/rsyslogd.conf
ADD postgres.conf /etc/supervisor/conf.d/postgres.conf


# Set the default command to run when starting the container
#CMD ["/usr/lib/postgresql/9.4/bin/postgres", "-D", "/var/lib/postgresql/9.4/main", "-c", "config_file=/etc/postgresql/9.4/main/postgresql.conf"]
CMD /bin/bash -c "/usr/bin/supervisord && tail -f /dev/null"


# Add VOLUMEs to allow backup of config, logs and datas
VOLUME  ["/var/lib/postgresql"]

EXPOSE 5432
