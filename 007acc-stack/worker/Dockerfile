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

FROM devopscenter/007acc.web:dcSTACK_VERSION
MAINTAINER josh < josh [at] devops {dot} center>

# Flower port
EXPOSE 5555

ADD worker.sh /installs/worker.sh
WORKDIR /installs

RUN ./worker.sh

# Setup config to run pgpool, celery, and flower in this container
# (basically don't run nginx and uwsgi)

RUN rm -rf /etc/supervisor/conf.d/uwsgi.conf && \
    rm -rf /etc/supervisor/conf.d/run_uwsgi.conf && \
    rm -rf /etc/supervisor/conf.d/nginx.conf

# Run supervisor in this container, in foreground mode. However first establish link for logging container,
# then grab any app-supplied configs for celery and flower (if present),
# then remove stale PIDs which prevented pgpool from successfully running from a container that is restarted.

CMD ln -sf /var/run/rsyslog/dev/log /dev/log && \
    if [ -e /app-utils/conf/supervisor-celery.conf ]; then cp /app-utils/conf/supervisor-celery.conf /etc/supervisor/conf.d/celery.conf; fi && \
    if [ -e /app-utils/conf/supervisor-flower.conf ]; then cp /app-utils/conf/supervisor-flower.conf //etc/supervisor/conf.d/flower.conf; fi && \
    if [ -e /app-utils/conf/run_celery.sh ]; then cp /app-utils/conf/run_celery.sh /etc/supervisor/conf.d/; fi && \
    rm -rf /var/run/pgpool/.s.* && \
    rm -rf /tmp/.s.* && \
    rm -rf /var/run/pgpool/pgpool.pid && \
    rm -rf /var/run/postgresql/.s.* && \
    supervisord -n
