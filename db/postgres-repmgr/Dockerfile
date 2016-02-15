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
FROM devopscenter/db_postgres:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

USER root
RUN cd /tmp && wget http://www.repmgr.org/download/repmgr-2.0.tar.gz && tar -xvf repmgr-2.0.tar.gz
#RUN cd /tmp && wget https://github.com/2ndQuadrant/repmgr/archive/v2.0.1.zip
RUN sudo apt-fast -y install libpam-dev libxml2-dev libxslt-dev
RUN sudo apt-fast -y install libedit-dev libselinux-dev
RUN cd /tmp/repmgr-2.0 && make USE_PGXS=1
RUN cd /tmp/repmgr-2.0 && make USE_PGXS=1 install

USER postgres
