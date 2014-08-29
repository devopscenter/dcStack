FROM devopscenter/python-apache-pgpool:0.1.2
MAINTAINER josh < josh [at] devops {dot} center>

#Need redis-cli and libs
RUN cd / && wget http://download.redis.io/releases/redis-2.8.13.tar.gz
RUN cd / && tar xvzf redis-2.8.13.tar.gz
RUN cd /redis-2.8.13 && make -j 3 && make install
