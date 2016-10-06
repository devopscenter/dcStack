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

FROM devopscenter/db_base:devops_version
MAINTAINER bob < bob [at] devops {dot} center>

ENV POSTGRES_VERSION 9.4

WORKDIR /installs/utils

ADD postgres.sh /installs/postgres.sh
ADD config.sh /installs/config.sh
ADD xlog.sh /installs/xlog.sh
ADD conf /installs/conf
ADD hstore.sh /installs/hstore.sh
ADD postgresenv.sh /installs/postgresenv.sh
ADD supervisorconfig.sh /installs/supervisorconfig.sh

WORKDIR /installs
RUN ./postgres.sh $POSTGRES_VERSION && \
    cp conf/postgresql.conf.local /media/data/postgres/db/pgdata/postgresql.conf

# Run supervisor in this container, in foreground mode
CMD ln -sf /var/run/rsyslog/dev/log /dev/log && /usr/local/bin/supervisord -n

# Add VOLUMEs to allow backup of config, logs and datas 
VOLUME  ["/media/data/postgres/db/pgdata", \
	 ”/media/data/postgres/xlog”, \
	 “/media/data/postgres/backup”]

EXPOSE 5432
