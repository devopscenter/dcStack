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

FROM ubuntu:trusty
MAINTAINER josh < josh [at] devops {dot} center>

RUN apt-get update && apt-get -y install python-software-properties software-properties-common
RUN add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN apt-get update

RUN add-apt-repository ppa:saiarcot895/myppa
RUN apt-get update
RUN apt-get -y install apt-fast

RUN apt-fast update
RUN apt-fast -y install wget sudo vim curl
RUN apt-fast -y install build-essential
RUN apt-fast -y install libpcre3 libpcre3-dev libssl-dev

RUN cd /tmp && wget http://www.haproxy.org/download/1.5/src/haproxy-1.5.9.tar.gz
RUN cd /tmp && tar -xvf haproxy-1.5.9.tar.gz
RUN cd /tmp/haproxy-1.5.9 && make -j 3 TARGET=linux2628 USE_STATIC_PCRE=1 USE_OPENSSL=yes && make install

EXPOSE 80 443

ADD haproxy.cfg /etc/haproxy/haproxy.cfg

CMD haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid && tail -f /dev/null

RUN echo "$ModLoad imudp" >> /etc/rsyslog.conf
RUN echo "$UDPServerAddress 127.0.0.1" >> /etc/rsyslog.conf
RUN echo "$UDPServerRun 514" >> /etc/rsyslog.conf

RUN touch /etc/rsyslog.d/haproxy.conf 
RUN echo "if ($programname == 'haproxy') then -/var/log/haproxy.log" >> /etc/rsyslog.d/haproxy.conf
