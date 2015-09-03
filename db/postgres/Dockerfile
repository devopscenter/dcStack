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


# Adjust PostgreSQL configuration so that remote connections to the
# data are possible. 
ADD pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/9.4/main/pg_hba.conf


USER postgres

RUN echo "host all          all    0.0.0.0/0  trust" >> /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf
RUN echo "host replication  all    0.0.0.0/0  trust" >> /etc/postgresql/${POSTGRES_VERSION}/main/pg_hba.conf

ENV POSTGRES_CONF /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
# And add ``listen_addresses`` 
RUN echo "listen_addresses='*'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf

# ssl not needed for now. also gives error on boot2docker
RUN echo "ssl = false                              # (change requires restart)" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "wal_level = hot_standby          # minimal, archive, or hot_standby" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "hot_standby = on            # 'on' allows queries during recovery" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "max_wal_senders = 20      # max number of walsender processes" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "log_destination = 'syslog'" >> $POSTGRES_CONF
RUN echo "syslog_facility = 'LOCAL0'" >> $POSTGRES_CONF
RUN echo "syslog_ident = 'postgres'" >> $POSTGRES_CONF
RUN echo "max_connections = 200" >> $POSTGRES_CONF
RUN echo "shared_buffers = 128MB" >> $POSTGRES_CONF
RUN echo "checkpoint_segments=16" >> $POSTGRES_CONF
#RUN echo "logging_collector = on" >> $POSTGRES_CONF
#RUN echo "log_directory = 'pg_log'" >> $POSTGRES_CONF
#RUN echo "log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'" >> $POSTGRES_CONF

# Set the default command to run when starting the container
#CMD ["/usr/lib/postgresql/9.4/bin/postgres", "-D", "/var/lib/postgresql/9.4/main", "-c", "config_file=/etc/postgresql/9.4/main/postgresql.conf"]
ADD postgres.conf /etc/supervisor/conf.d/postgres.conf
CMD /bin/bash -c "/usr/bin/supervisord && tail -f /dev/null"


USER postgres

RUN mkdir -p /var/run/postgresql/9.4-main.pg_stat_tmp

# stats configuration
ENV POSTGRES_PERF_CONF /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf.perf
RUN cp /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf $POSTGRES_PERF_CONF
RUN echo "shared_preload_libraries = 'auto_explain'" >> $POSTGRES_PERF_CONF
#RUN echo "custom_variable_classes = 'auto_explain'" >> $POSTGRES_PERF_CONF
RUN echo "auto_explain.log_min_duration = '10ms'" >> $POSTGRES_PERF_CONF
RUN echo "auto_explain.log_verbose = 'true'" >> $POSTGRES_PERF_CONF
RUN echo "auto_explain.log_analyze = 'true'" >> $POSTGRES_PERF_CONF

# wal-e configuration
ENV POSTGRES_WALE_CONF /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf.wale
RUN cp /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf $POSTGRES_WALE_CONF
RUN echo "archive_mode = on" >> $POSTGRES_WALE_CONF
RUN echo "archive_command = 'wal-e wal-push %p'" >> $POSTGRES_WALE_CONF
RUN echo "archive_timeout = 60" >> $POSTGRES_WALE_CONF


# pg_stats
#RUN echo "track_activities = 'true'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
#RUN echo "track_activity_query_size = 'true'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
#RUN echo "track_counts = 'true'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
#RUN echo "track_io_timing = 'true'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf

#Statistics Monitoring
#RUN echo "log_statement_stats = 'true'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
#RUN echo "log_parser_stats = 'true'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
#RUN echo "log_planner_stats = 'true'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
#RUN echo "log_executor_stats = 'true'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf

# HSTORE
RUN echo "CREATE EXTENSION hstore;" | \
    /bin/bash -c "/usr/lib/postgresql/9.4/bin/postgres --single \
    -D /var/lib/postgresql/9.4/main \
    -c config_file=$POSTGRES_CONF \
    template1"

USER root
RUN chown -R postgres:postgres /var/lib/postgresql 
ADD rsyslogd.conf /etc/supervisor/conf.d/rsyslogd.conf

# Add VOLUMEs to allow backup of config, logs and datas
VOLUME  ["/var/lib/postgresql"]

EXPOSE 5432
