FROM devopscenter/web_apache:devops_version
MAINTAINER josh < josh [at] devops {dot} center>

ENV HOME /root
ENV IS_DOCKER True
RUN cd /installs && wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh

ADD requirements.txt /requirements.txt
RUN cd / && pip install -r requirements.txt

RUN pip install django-sslserver==0.12

#Need redis-cli and libs
RUN cd / && wget http://download.redis.io/releases/redis-2.8.13.tar.gz
RUN cd / && tar xvzf redis-2.8.13.tar.gz
RUN cd /redis-2.8.13 && make -j 3 && make install

CMD /etc/init.d/pgpool start  && /usr/sbin/apache2 -D FOREGROUND
