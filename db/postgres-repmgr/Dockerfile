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
ARG COMPOSITE_TAG
FROM devopscenter/db_postgres:${COMPOSITE_TAG}
MAINTAINER josh < josh [at] devops {dot} center>

USER root
RUN cd /tmp && wget http://www.repmgr.org/download/repmgr-5.0.0.tar.gz && tar -xvf repmgr-5.0.0.tar.gz
RUN sudo apt-get -y install libpam-dev libxml2-dev libxslt-dev
RUN sudo apt-get -y install libedit-dev
RUN cd /tmp/repmgr-5.0.0 && make USE_PGXS=1
RUN cd /tmp/repmgr-5.0.0 && make USE_PGXS=1 install

USER postgres
