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

FROM devopscenter/python-apache-pgpool-redis:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

ENV IS_WORKER True

ADD \
    https://raw.githubusercontent.com/celery/celery/5ce97f1de36570a6b3c1eda84513cc6a8b3eb96e/extra/generic-init.d/celeryd \
        /etc/init.d/celeryd

ADD \
    https://raw.githubusercontent.com/celery/celery/5ce97f1de36570a6b3c1eda84513cc6a8b3eb96e/extra/generic-init.d/celerybeat \
    /etc/init.d/celerybeat

RUN chmod 755 /etc/init.d/celery*

RUN cd /redis-$REDIS_VERSION && \
mkdir -p /etc/redis && \
cp -f *.conf /etc/redis
