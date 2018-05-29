#
# Docker Stack - Docker stack to manage infrastructures
#
# Copyright 2015 devops.center
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

FROM devopscenter/python:dcSTACK_VERSION
MAINTAINER josh < josh [at] devops {dot} center>

ARG POSTGRES_VERSION
ENV POSTGRES_VERSION ${POSTGRES_VERSION}

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.4``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN sudo apt-fast update

RUN sudo apt-fast -y -q install postgresql-client-${POSTGRES_VERSION} libpq5 libpq-dev

RUN pip install git+https://github.com/josh-devops-center/newrelic-plugin-agent@5f1ec79094815486d26bc66a55b5ff1d1e97b6c7#egg=newrelic-plugin-agent
RUN pip install newrelic-plugin-agent[postgresql]

RUN mkdir -p /var/log/newrelic
RUN mkdir -p /var/run/newrelic

ADD newrelic-plugin-agent.cfg /etc/newrelic/newrelic-plugin-agent.cfg
ADD newrelic-plugin-agent.conf /etc/supervisor/conf.d/newrelic-plugin-agent.conf

CMD /bin/bash -c " /usr/bin/supervisord && tail -f /dev/null"

