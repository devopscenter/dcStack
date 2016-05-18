FROM ubuntu:trusty

ADD buildtools/utils/base-utils.sh /installs/base-utils.sh
ADD logging/papertrail.sh /installs/papertrail.sh
ADD logging/90-papertrailqueue.conf /installs/90-papertrailqueue.conf
ADD logging/50-default.conf /installs/50-default.conf

WORKDIR /installs
RUN ./base-utils.sh
RUN ./papertrail.sh
