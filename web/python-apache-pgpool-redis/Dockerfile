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

ENV REDIS_VERSION 3.0.3

#flower port
EXPOSE 5555

#onbuild requires images to extend to have these files, so place in this dockerfile instead of python dockerfile
ONBUILD ADD wheelhouse /wheelhouse
ONBUILD ADD requirements.txt /installs/requirements.txt
ONBUILD RUN cd /installs && pip install --no-index -r requirements.txt

ENV WHEELHOUSE=/wheelhouse
ENV PIP_WHEEL_DIR=/wheelhouse
ENV PIP_FIND_LINKS=/wheelhouse

