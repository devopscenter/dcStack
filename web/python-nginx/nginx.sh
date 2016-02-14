#!/bin/bash -ex

. ./nginxenv.sh

sudo useradd uwsgi

sudo apt-fast install supervisor rsyslog-gnutls

pushd /tmp
wget --quiet ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.bz2 && \
    tar -xvf pcre-8.38.tar.bz2
pushd pcre-8.38 
./configure && make --silent -j 3 && sudo make --silent install
popd

wget --quiet http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && tar -xvf nginx-$NGINX_VERSION.tar.gz
pushd nginx-$NGINX_VERSION 
./configure --with-http_stub_status_module && sudo make --silent -j 3 && sudo make --silent install
popd

sudo pip install uwsgi==$UWSGI_VERSION && \
    sudo mkdir -p /var/log/uwsgi && \
    sudo mkdir -p /var/run/uwsgi && \
    sudo chown -R uwsgi /var/run/uwsgi && \
    sudo chown -R uwsgi /var/log/uwsgi

popd

sudo cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
sudo cp conf/supervisor-nginx.conf /etc/supervisor/conf.d/nginx.conf
sudo cp conf/supervisor-uwsgi.conf /etc/supervisor/conf.d/uwsgi.conf
sudo cp conf/supervisor-rsyslogd.conf /etc/supervisor/conf.d/rsyslogd.conf

