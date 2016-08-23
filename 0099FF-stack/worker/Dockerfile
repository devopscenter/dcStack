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

FROM devopscenter/0099ff.web:devops_version
MAINTAINER bob < bob [at] devops {dot} center>

ADD supervisor-djangorq-worker.conf /installs/supervisor-djangorq-worker.conf

# Setup config to run pgpool and a single django-rq worker in this container
# (though this requires supervisor)
RUN rm /etc/supervisor/conf.d/nginx.conf && \
    rm /etc/supervisor/conf.d/uwsgi.conf && \
    cp supervisor-djangorq-worker.conf /etc/supervisor/conf.d/djangorq-worker.conf

# Finally, run supervisor in this container, in foreground mode

CMD ln -sf /var/run/rsyslog/dev/log /dev/log && supervisord -n


