FROM devopscenter/web_apache:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

ENV IS_WORKER True

ADD \
    https://raw.githubusercontent.com/celery/celery/5ce97f1de36570a6b3c1eda84513cc6a8b3eb96e/extra/generic-init.d/celeryd \
        /etc/init.d/celeryd

ADD \
    https://raw.githubusercontent.com/celery/celery/5ce97f1de36570a6b3c1eda84513cc6a8b3eb96e/extra/generic-init.d/celerybeat \
    /etc/init.d/celerybeat

RUN chmod 755 /etc/init.d/celery*

RUN cd /redis-2.8.13 && \
mkdir -p /etc/redis && \
cp -f *.conf /etc/redis
