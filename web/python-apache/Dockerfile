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

RUN cd /tmp && wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.36.tar.bz2
RUN cd /tmp && tar -xvf pcre-8.36.tar.bz2
RUN cd /tmp/pcre-8.36 && ./configure && make -j 3 && make install

ADD http://archive.apache.org/dist/httpd/httpd-2.4.10.tar.bz2 /tmp/httpd-2.4.10.tar.bz2
ADD http://www.us.apache.org/dist/apr/apr-util-1.5.4.tar.gz /tmp/apr-util-1.5.4.tar.gz
ADD http://www.us.apache.org/dist/apr/apr-1.5.1.tar.bz2 /tmp/apr-1.5.1.tar.bz2
#ADD http://www.us.apache.org/dist/apr/apr-1.5.1.tar.bz2 /tmp/apr-1.5.1.tar.bz2

RUN cd /tmp && tar -xf httpd-2.4.10.tar.bz2
RUN cd /tmp && tar -xf apr-1.5.1.tar.bz2
RUN cd /tmp && tar -xf apr-util-1.5.4.tar.gz

RUN mv /tmp/apr-util-1.5.4 /tmp/httpd-2.4.10/srclib/apr-util
RUN mv /tmp/apr-1.5.1  /tmp/httpd-2.4.10/srclib/apr

RUN cd /tmp/httpd-2.4.10 && ./configure --with-mpm=worker --with-included-apr --enable-mods-shared="most status"
RUN cd /tmp/httpd-2.4.10 && make -j 3 && make install

RUN cd /tmp && wget https://github.com/GrahamDumpleton/mod_wsgi/archive/4.2.8.tar.gz && tar -xvf 4.2.8.tar.gz
RUN which python && python --version
ENV PATH $PATH:/usr/local/apache2/bin/
RUN ldconfig
RUN cd /tmp/mod_wsgi-4.2.8 && ./configure --with-python=/usr/local/opt/python/bin/python --quiet && make && make install

RUN ln -s /usr/local/apache2/bin/apachectl /etc/init.d/apache2
