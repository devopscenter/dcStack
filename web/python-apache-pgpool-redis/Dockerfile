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

FROM devopscenter/python-apache-pgpool:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

#Need redis-cli and libs
ENV REDIS_VERSION 2.8.17
RUN cd / && wget http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz
RUN cd / && tar xvzf redis-$REDIS_VERSION.tar.gz
RUN cd /redis-$REDIS_VERSION && make -j 3 && make install

ONBUILD ADD requirements.txt /requirements.txt
ONBUILD RUN cd / && pip install -r requirements.txt

ONBUILD ADD apache/django.conf /etc/apache2/django.conf
ONBUILD RUN echo "Include django.conf" | sudo tee -a /etc/apache2/apache2.conf
