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

ENV APACHE_VERSION 2.4.7-1ubuntu4.1
ENV MODWSGI_VERSION 3.4-4ubuntu2.1.14.04.1

#https://github.com/jacksoncage/apache-docker
RUN sudo apt-fast -y install apache2=$APACHE_VERSION apache2-prefork-dev #libapache2-mod-wsgi=$MODWSGI_VERSION

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www


RUN cd /tmp && wget https://github.com/GrahamDumpleton/mod_wsgi/archive/4.2.8.tar.gz && tar -xvf 4.2.8.tar.gz
RUN which python && python --version
RUN cd /tmp/mod_wsgi-4.2.8 && ./configure --with-python=/usr/local/opt/python/bin/python --quiet && make && make install
