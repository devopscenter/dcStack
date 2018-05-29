#
# Docker Stack - Docker stack to manage infrastructures
#
# Copyright 2014 - 2017 devops.center
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

FROM devopscenter/php-nginx:dcSTACK_VERSION
MAINTAINER bob < bob [at] devops {dot} center>

WORKDIR /installs
ADD web.sh /installs/web.sh

# the config files specific to this app stack
# (note that the config files specific to the ENV are mounted in docker-compose)
ADD conf /installs/conf

RUN ./web.sh

# Run supervisor in this container, in foreground mode. However first establish link for logging container,
# copy over a local nginx config file (if it exists), then remove stale PIDs which prevented pgpool from
# successfully running from a container that is restarted.

CMD ln -sf /var/run/rsyslog/dev/log /dev/log && \
    if [ -e /app-utils/conf/web-commands.sh ]; then  /app-utils/conf/web-commands.sh; fi && \
    rm -rf /tmp/.s.* && \
    supervisord -n
