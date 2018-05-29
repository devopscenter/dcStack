ARG baseimageversion
FROM ${baseimageversion}
MAINTAINER Bob Lozano <bob@devops.center>

RUN apt-get update && \
    apt-get install rsyslog --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm /etc/rsyslog.d/50-default.conf

COPY docker-rsyslog.conf /etc/rsyslog.conf

VOLUME /var/run/rsyslog/dev
EXPOSE 514/tcp 514/udp

CMD ["rsyslogd", "-n"]
