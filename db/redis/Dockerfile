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

FROM redis:3.0.0
MAINTAINER josh < josh [at] devops {dot} center>

RUN apt-get update
RUN apt-get -y install supervisor

ADD redis.conf /etc/supervisor/conf.d/redis.conf

ADD https://raw.githubusercontent.com/antirez/redis/3.0.0/redis.conf /etc/redis/redis.conf
RUN echo "dir /data" >> /etc/redis/redis.conf
RUN echo "syslog-enabled yes" >> /etc/redis/redis.conf
RUN echo "syslog-ident redis" >> /etc/redis/redis.conf
RUN echo "syslog-facility local0" >> /etc/redis/redis.conf

CMD /bin/bash -c "/usr/bin/supervisord && tail -f /dev/null"
