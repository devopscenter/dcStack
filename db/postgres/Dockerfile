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

FROM baseimageversion
MAINTAINER josh < josh [at] devops {dot} center>

ADD postgres.sh /installs/postgres.sh
ADD config.sh /installs/config.sh
ADD xlog.sh /installs/xlog.sh
ADD conf /installs/conf
ADD hstore.sh /installs/hstore.sh

WORKDIR /installs

RUN ./postgres.sh

USER postgres

RUN ./config.sh

USER root

RUN ./xlog.sh
RUN ./supervisorconfig.sh

# Set the default command to run when starting the container
CMD /bin/bash -c "/usr/bin/supervisord && tail -f /dev/null"

# Add VOLUMEs to allow backup of config, logs and datas
VOLUME  ["/media/data/postgres/db"]

EXPOSE 5432
