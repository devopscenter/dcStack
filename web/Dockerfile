FROM ubuntu:trusty
MAINTAINER josh < josh [at] devops {dot} center>

RUN apt-get update && apt-get -y install python-software-properties software-properties-common
RUN add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN apt-get update

RUN add-apt-repository ppa:saiarcot895/myppa
RUN apt-get update
RUN apt-get -y install apt-fast

ENV GIT_VERSION 1:2.1.0-1~ppa0~ubuntu14.04.1
ENV PYTHONPIP_VERSION 1.5.4
ENV APACHE_VERSION 2.4.7-1ubuntu4.1
ENV MODWSGI_VERSION 3.4-4ubuntu2.1.14.04.1
ENV PYTHON_VERSION 2.7.8
ENV PYTHONPIP_VERSION 1.5.4
ENV POSTGRES_VERSION 9.3

RUN add-apt-repository ppa:git-core/ppa
RUN apt-fast update
#RUN apt-cache showpkg git python-dev apache2 libapache2-mod-wsgi python-pip curl
RUN apt-fast -y install git=$GIT_VERSION

RUN apt-fast -y install wget sudo vim curl
RUN apt-fast -y install build-essential

RUN apt-fast -y install sqlite3 libsqlite3-dev libssl-dev zlib1g-dev libxml2-dev libbz2-dev
ADD https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz /tmp/Python-2.7.8.tgz
RUN cd /tmp && tar -xvf Python-2.7.8.tgz
RUN cd /tmp/Python-2.7.8 && ./configure --quiet && make -j3 && make altinstall

RUN ln -s /usr/local/bin/python2.7 /usr/local/bin/python


RUN cd /tmp && wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

RUN pip install distribute==0.6.49 && pip install -U setuptools && pip install -U pip

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN sudo apt-fast update

RUN sudo apt-fast -y -q install postgresql-$POSTGRES_VERSION postgresql-client-$POSTGRES_VERSION \
        postgresql-contrib-$POSTGRES_VERSION postgresql-server-dev-$POSTGRES_VERSION


RUN mkdir /installs
RUN cd /installs && wget http://www.pgpool.net/download.php?f=pgpool-II-3.3.3.tar.gz -O pgpool-II-3.3.3.tar.gz
RUN cd /installs && tar -xvf pgpool-II-3.3.3.tar.gz
RUN cd /installs/pgpool-II-3.3.3 && ./configure && make && make install

#https://github.com/jacksoncage/apache-docker
RUN sudo apt-fast -y install apache2=$APACHE_VERSION libapache2-mod-wsgi=$MODWSGI_VERSION

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
