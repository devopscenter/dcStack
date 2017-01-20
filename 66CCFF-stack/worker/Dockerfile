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

FROM devopscenter/66ccff.web:dcSTACK_VERSION
MAINTAINER josh < josh [at] devops {dot} center>

# Setup config to run pgpool, celery, and flower in this container
# (this requires supervisor)

RUN rm -rf /etc/supervisor/conf.d/nginx.conf && \
    rm -rf /etc/supervisor/conf.d/uwsgi.conf

ADD flower.conf /etc/supervisor/conf.d/flower.conf
ADD celery.conf /etc/supervisor/conf.d/celery.conf


# Run supervisor in this container, in foreground mode. However first establish link for logging container,
# then remove stale PIDs which prevented pgpool from successfully running from a container that is restarted.

CMD ln -sf /var/run/rsyslog/dev/log /dev/log && \
    rm -rf /var/run/pgpool/.s.* && \
    rm -rf /tmp/.s.* && \
    rm -rf /var/run/pgpool/pgpool.pid && \
    rm -rf /var/run/postgresql/.s.* && \
    supervisord -n
