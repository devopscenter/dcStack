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
ENV PGPOOL_VERSION 3.4.2


ADD pgpool.sh /installs/pgpool.sh
WORKDIR /installs
RUN ./pgpool.sh


ADD pgpool/pgpool2.init.d /etc/init.d/pgpool
ADD pgpool.conf /etc/supervisor/conf.d/pgpool.conf

ADD pgpool/pool_hba.conf /etc/pgpool2/pool_hba.conf
ADD pgpool/pgpool.conf.one /etc/pgpool2/pgpool.conf.one
ADD pgpool/pgpool.conf.two /etc/pgpool2/pgpool.conf.two
ADD pgpool/pgpool.conf.three /etc/pgpool2/pgpool.conf.three
ADD pgpool/pcp.conf /etc/pgpool2/pcp.conf

CMD /bin/bash -c "rm -rf /var/run/pgpool/pgpool.pid && rm -rf /var/run/postgresql/.s.* && /usr/bin/supervisord && tail -f /dev/null"
