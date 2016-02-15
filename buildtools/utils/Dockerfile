FROM ubuntu:trusty

ADD base-utils.sh /installs/base-utils.sh
ADD papertrail.sh /installs/papertrail.sh
ADD papertrail.conf /installs/papertrail.conf

WORKDIR /installs
RUN ./base-utils.sh
RUN ./papertrail.sh
