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
FROM devopscenter/python:${COMPOSITE_TAG}
MAINTAINER josh < josh [at] devops {dot} center>

EXPOSE 80 8000 443

ADD nginxenv.sh /installs/nginxenv.sh
ADD nginx.sh /installs/nginx.sh
ADD conf /installs/conf
WORKDIR /installs
RUN ./nginx.sh

