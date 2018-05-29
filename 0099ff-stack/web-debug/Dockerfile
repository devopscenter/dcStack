#
# Docker Stack - Docker stack to manage infrastructures
#
# WEB-DEBUG Container
#   This container is designed to provide an interactive debugging environment for the first step in a dev
#   workflow. Provides a connection to the db (via pgpool), and an additional ENV var (IS_DC_WEB_DEBUG) to
#   permit settings.py to install the django sslserver, etc for interactive dev.
#
# Notes
# - django ssl server: https://github.com/teddziuba/django-sslserver
# - to start the ssl server: "python manage.py runsslserver 0.0.0.0:8000"
#   responding on any ip address is needed because localhost means something different to the host, 
#   host vm (if any), and within each container. 
# - set the django site_base_url to "127.0.0.0:8000"
#
# Copyright 2014 - 2016 devops.center
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

ARG COMPOSIT_TAG
FROM devopscenter/0099ff.web:${COMPOSIT_TAG}
MAINTAINER bob < bob [at] devops {dot} center>

ENV IS_DC_WEB_DEBUG=1

# Setup config to run pgpool in this container
# (requires supervisor)
RUN rm -rf /etc/supervisor/conf.d/nginx.conf && \
    rm -rf /etc/supervisor/conf.d/uwsgi.conf && \

# Install django ssl-server for local, interactive debugging while serving the site
    pip install django-sslserver

# Run supervisor in this container, in foreground mode. However first establish link for logging container,
# then remove stale PIDs which prevented pgpool from successfully running from a container that is restarted.

CMD ln -sf /var/run/rsyslog/dev/log /dev/log && \
    rm -rf /var/run/pgpool/.s.* && \
    rm -rf /tmp/.s.* && \
    rm -rf /var/run/pgpool/pgpool.pid && \
    rm -rf /var/run/postgresql/.s.* && \
    supervisord -n


