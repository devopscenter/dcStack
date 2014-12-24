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

FROM devopscenter/db_postgres:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

RUN echo "log_destination = 'csvlog'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "logging_collector = on" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "log_directory = 'pg_log'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "shared_preload_libraries = 'auto_explain'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
#RUN echo "custom_variable_classes = 'auto_explain'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "auto_explain.log_min_duration = '10ms'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "auto_explain.log_verbose = 'true'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf
RUN echo "auto_explain.log_analyze = 'true'" >> /etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf

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

# Set the default command to run when starting the container
#CMD ["/usr/lib/postgresql/${POSTGRES_VERSION}/bin/postgres", "-D", "/var/lib/postgresql/${POSTGRES_VERSION}/main", "-c", "config_file=/etc/postgresql/${POSTGRES_VERSION}/main/postgresql.conf"]

#be able to restart container without shutting down in fig, so start postgres service manually
CMD tail -f /dev/null
