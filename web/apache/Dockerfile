FROM devopscenter/python:0.1.2
MAINTAINER josh < josh [at] devops {dot} center>

ENV APACHE_VERSION 2.4.7-1ubuntu4.1
ENV MODWSGI_VERSION 3.4-4ubuntu2.1.14.04.1
ENV POSTGRES_VERSION 9.3

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN sudo apt-fast update

RUN sudo apt-fast -y -q install postgresql-client-$POSTGRES_VERSION libpq-dev
#        postgresql-contrib-$POSTGRES_VERSION postgresql-server-dev-$POSTGRES_VERSION

#not installing postgres server, so manually create user
RUN useradd postgres -m -s /bin/bash
#RUN groupadd postgres
RUN usermod -a -G postgres postgres


RUN mkdir /installs
RUN cd /installs && wget http://www.pgpool.net/download.php?f=pgpool-II-3.3.3.tar.gz -O pgpool-II-3.3.3.tar.gz
RUN cd /installs && tar -xvf pgpool-II-3.3.3.tar.gz
RUN cd /installs/pgpool-II-3.3.3 && ./configure && make && make install

#https://github.com/jacksoncage/apache-docker
RUN sudo apt-fast -y install apache2=$APACHE_VERSION apache2-prefork-dev #libapache2-mod-wsgi=$MODWSGI_VERSION

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www


RUN cd /tmp && wget https://github.com/GrahamDumpleton/mod_wsgi/archive/4.2.8.tar.gz && tar -xvf 4.2.8.tar.gz
RUN which python && python --version
RUN cd /tmp/mod_wsgi-4.2.8 && ./configure --with-python=/usr/local/opt/python/bin/python --quiet && make && make install

RUN mkdir -p -m 700 /etc/pgpool2 && chown -R postgres:postgres /etc/pgpool2
RUN mkdir -p -m 755 /var/log/pgpool && chown -R postgres:postgres /var/log/pgpool
ADD pgpool/pgpool2.init.d /etc/init.d/pgpool
RUN chmod 755 /etc/init.d/pgpool
#USER postgres
ADD pgpool/pool_hba.conf /etc/pgpool2/pool_hba.conf
ADD pgpool/pgpool.conf /etc/pgpool2/pgpool.conf
ADD pgpool/pcp.conf /etc/pgpool2/pcp.conf
RUN chown -R postgres:postgres /etc/pgpool2

#Need redis-cli and libs
RUN cd / && wget http://download.redis.io/releases/redis-2.8.13.tar.gz
RUN cd / && tar xvzf redis-2.8.13.tar.gz
RUN cd /redis-2.8.13 && make -j 3 && make install
