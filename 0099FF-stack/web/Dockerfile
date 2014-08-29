FROM devopscenter/python-apache-pgpool-redis:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

ENV HOME /root
ENV IS_DOCKER True

RUN cd / && wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh

ADD requirements.txt /requirements.txt
RUN cd / && pip install -r requirements.txt

RUN pip install django-sslserver==0.12

CMD /etc/init.d/pgpool start  && /etc/init.d/apache2 start
