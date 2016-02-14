FROM ubuntu:trusty

ADD base-utils.sh /installs/base-utils.sh
ADD papertrail.sh /installs/papertrail.sh

WORKDIR /installs
RUN ./base-utils.sh
RUN ./papertrail.sh
