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


FROM devopscenter/db_base:v2.0b1

MAINTAINER josh < josh [at] devops {dot} center>

WORKDIR /installs/utils

ADD redisinstall.sh /installs/redisinstall.sh
ADD conf /installs/conf
WORKDIR /installs
RUN ./redisinstall.sh

VOLUME /media/data/redis
WORKDIR /media/data/redis
EXPOSE 6379

# Run redis
CMD /usr/local/bin/redis-server /etc/redis/redis.conf
