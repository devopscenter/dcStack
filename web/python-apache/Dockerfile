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

FROM devopscenter/python:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

ENV NGINX_VERSION 1.7.12
ENV UWSGI_VERSION 2.0.11

RUN useradd uwsgi

RUN apt-fast -y install supervisor

RUN cd /tmp && wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.36.tar.bz2 && \
cd /tmp && tar -xvf pcre-8.36.tar.bz2 && \
cd /tmp/pcre-8.36 && ./configure && make -j 3 && make install

RUN cd /tmp && wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && tar -xvf nginx-$NGINX_VERSION.tar.gz && \
cd /tmp/nginx-$NGINX_VERSION && ./configure --with-http_stub_status_module && make -j 3 && make install
ADD nginx/nginx.conf /usr/local/nginx/conf/nginx.conf
RUN pip install uwsgi==$UWSGI_VERSION && \
mkdir -p /var/log/uwsgi && \
mkdir -p /var/run/uwsgi && \
chown -R uwsgi /var/run/uwsgi && \
chown -R uwsgi /var/log/uwsgi

EXPOSE 80 8000 443

ADD nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD uwsgi.conf /etc/supervisor/conf.d/uwsgi.conf
ADD rsyslogd.conf /etc/supervisor/conf.d/rsyslogd.conf
