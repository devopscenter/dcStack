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

RUN apt-fast install -y gfortran libopenblas-dev liblapack-dev supervisor
ADD science.txt /science.txt
RUN cd / && pip wheel --wheel-dir=/wheel -r science.txt && \
cd / && pip install --use-wheel --no-index --find-links=/wheel -r science.txt

ADD pgpool.conf /etc/supervisor/conf.d/pgpool.conf
ADD nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD uwsgi.conf /etc/supervisor/conf.d/uwsgi.conf

CMD /bin/bash -c "rm -rf /var/run/pgpool/pgpool.pid && rm -rf /var/run/postgresql/.*.s* && /usr/bin/supervisord && tail -f /dev/null"
