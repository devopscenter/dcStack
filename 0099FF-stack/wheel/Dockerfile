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

FROM devopscenter/python-apache-pgpool-redis:0.5.39
MAINTAINER josh < josh [at] devops {dot} center>

ENV WHEEL_DIR /wheel
ENV DOWNLOAD_DIR /downloads
ENV REQUIREMENTS r.txt
ENV REQUIREMENTS_LOCATION /requirements.txt

ADD $REQUIREMENTS $REQUIREMENTS_LOCATION
ADD wheel $WHEEL_DIR

RUN mkdir -p $DOWNLOAD_DIR

RUN pip wheel \
    --use-wheel \
    --wheel-dir=$WHEEL_DIR \
    --find-links=$WHEEL_DIR \
    --find-links=https://pythonwheels.com/ \ 
    --download-cache=$DOWNLOAD_DIR \
    -r $REQUIREMENTS_LOCATION

RUN pip install pip-tools && \
pip-review && \
cd $WHEEL_DIR && cp $REQUIREMENTS_LOCATION $WHEEL_DIR/requirements.txt && pip-dump && cat $WHEEL_DIR/requirements.txt

#RUN cd / && pip wheel --find-links=http://pythonwheels.com/ --wheel-dir=/wheel -r /requirements.txt && \
#pip freeze --local | grep -v Django | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U && \
#pip freeze > /wheel/requirements.txt
