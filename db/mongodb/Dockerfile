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

FROM devopscenter/db_base:dcSTACK_VERSION
MAINTAINER bob < bob [at] devops {dot} center>

ENV MONGODB_VERSION 3.6

WORKDIR /root/installs

ADD mongodb.sh /root/installs/mongodb.sh
ADD config.sh /root/installs/config.sh
ADD conf /root/installs/conf
ADD mongodbenv.sh /root/installs/mongodbenv.sh
ADD supervisorconfig.sh /root/installs/supervisorconfig.sh

RUN ./mongodb.sh ${MONGODB_VERSION}
#RUN ./mongodb.sh $MONGODB_VERSION && \
#    cp conf/postgresql.conf.local /media/data/postgres/db/pgdata/postgresql.conf

# Run supervisor in this container, in foreground mode
CMD ln -sf /var/run/rsyslog/dev/log /dev/log && /usr/local/bin/supervisord -n

# Add mountpoints for VOLUMES to be created. Note that these mirror what is established
# when these are created in instances. Each of the four mountpoints are different types of data,
# and so can conceivably be put on different types of volumes.
VOLUME  ["/media/data/mongodb", \
    	 "/media/data/mongodb/db", \
    	 "/media/data/mongodb/backup"]
#VOLUME  ["/media/data/postgres", \
    #	 "/media/data/postgres/db/pgdata", \
    # "/media/data/postgres/xlog", \
    #	 "/media/data/postgres/backup"]

WORKDIR /root
EXPOSE 5432
