FROM devopscenter/web_apache:0.1.2
MAINTAINER josh < josh [at] devops {dot} center>

ENV IS_WORKER True

RUN cd /redis-2.8.13 && \
mkdir -p /etc/redis && \
cp -f *.conf /etc/redis
