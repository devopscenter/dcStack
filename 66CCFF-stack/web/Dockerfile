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

FROM devopscenter/python-apache-pgpool-redis:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

ADD apache/pdfcreator.conf /usr/local/apache2/conf/pdfcreator.conf
RUN echo "Include conf/pdfcreator.conf" | sudo tee -a /usr/local/apache2/conf/httpd.conf

CMD /etc/init.d/pgpool start  && /etc/init.d/apache2 start && tail -f /dev/null

RUN apt-fast -y install libfontconfig-dev libxrender-dev libxtst6
