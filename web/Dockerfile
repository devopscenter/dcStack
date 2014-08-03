FROM ubuntu:precise
MAINTAINER josh < josh [at] devops {dot} center>

RUN apt-get update && apt-get -y install python-software-properties software-properties-common
RUN add-apt-repository "deb http://gb.archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN apt-get update

RUN add-apt-repository ppa:apt-fast/stable
RUN apt-get update
RUN apt-get -y install apt-fast

RUN apt-fast -y install git python-dev python-pip wget sudo vim curl

RUN pip install distribute==0.6.49 && pip install -U setuptools && pip install -U pip

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN sudo apt-fast update

RUN sudo apt-fast -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 postgresql-server-dev-9.3

RUN sudo apt-fast -y -q install build-essential

RUN mkdir /installs
RUN cd /installs && wget http://www.pgpool.net/download.php?f=pgpool-II-3.3.3.tar.gz -O pgpool-II-3.3.3.tar.gz
RUN cd /installs && tar -xvf pgpool-II-3.3.3.tar.gz
RUN cd /installs/pgpool-II-3.3.3 && ./configure && make && make install

#https://github.com/jacksoncage/apache-docker
RUN sudo apt-fast -y install apache2 libapache2-mod-wsgi

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

#CMD ["/usr/sbin/apache2","-D", "FOREGROUND","&&","/etc/init.d/pgpool","start"]
#CMD /etc/init.d/pgpool start && /usr/sbin/apache2 -D FOREGROUND

