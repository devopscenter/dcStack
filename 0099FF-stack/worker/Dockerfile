FROM devopscenter/python-apache-pgpool-redis:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

ENV HOME /root
ENV IS_DOCKER True
ENV IS_WORKER True

ADD requirements.txt /requirements.txt
RUN cd / && pip install -r requirements.txt

RUN cd /redis-2.8.13 && \
mkdir -p /etc/redis && \
cp -f *.conf /etc/redis

CMD /etc/init.d/pgpool start && redis-server /etc/redis/redis.conf
