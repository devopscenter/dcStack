FROM devopscenter/python-apache:0.1.2
MAINTAINER josh < josh [at] devops {dot} center>

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

RUN mkdir -p -m 700 /etc/pgpool2 && chown -R postgres:postgres /etc/pgpool2
RUN mkdir -p -m 755 /var/log/pgpool && chown -R postgres:postgres /var/log/pgpool
ADD pgpool/pgpool2.init.d /etc/init.d/pgpool
RUN chmod 755 /etc/init.d/pgpool
#USER postgres
ADD pgpool/pool_hba.conf /etc/pgpool2/pool_hba.conf
ADD pgpool/pgpool.conf /etc/pgpool2/pgpool.conf
ADD pgpool/pcp.conf /etc/pgpool2/pcp.conf
RUN chown -R postgres:postgres /etc/pgpool2
