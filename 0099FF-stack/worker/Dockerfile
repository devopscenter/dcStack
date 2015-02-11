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

FROM devopscenter/0099ff.web2:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

ENV IS_WORKER True

RUN cd /redis-$REDIS_VERSION && \
mkdir -p /etc/redis && \
cp -f *.conf /etc/redis

ADD https://raw.githubusercontent.com/celery/celery/3.1/extra/generic-init.d/celeryd /etc/init.d/celeryd
ADD https://raw.githubusercontent.com/celery/celery/3.1/extra/generic-init.d/celerybeat /etc/init.d/celerybeat
ADD celeryd /etc/default/celeryd
RUN chmod 755 /etc/init.d/celery* && \
useradd celery && \
chmod 640 /etc/default/celeryd

ADD flower.conf /etc/supervisor/conf.d/flower.conf
ADD redis.conf /etc/supervisor/conf.d/redis.conf

CMD /bin/bash -c "rm -rf /var/run/pgpoo/pgpool.pid && rm -rf /var/run/postgresql/.s.PGSQL.* && /etc/init.d/pgpool start && /usr/bin/supervisord && /etc/init.d/celeryd stop && /etc/init.d/celeryd start "
