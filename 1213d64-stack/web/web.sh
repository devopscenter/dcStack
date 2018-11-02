#!/usr/bin/env bash
#===============================================================================
#
#          FILE: web.sh
#
#         USAGE: web.sh
#
#   DESCRIPTION: install what is necessary for the web container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 11/21/2016 15:13:37
#      REVISION:  ---
#
# Copyright 2014-2017 devops.center llc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#===============================================================================

#set -o nounset     # Treat unset variables as an error
#set -o errexit      # exit immediately if command exits with a non-zero status
#set -x             # essentially debug mode


source /usr/local/bin/dcEnv.sh                       # initalize logging environment

dcStartLog "install of app-specific web for 1213d64-stack (dcMonitoring)"

# update 
sudo apt-get update

# add the www user
useradd www

# prerequisites 
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y pdsh gunicorn \
 python-dev python-flup python-ldap expect memcached \
 sqlite3 libcairo2 libcairo2-dev libffi-dev librrd-dev python-cairo python-rrdtool 

# Install node
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -

sudo apt-get install -y nodejs

sudo apt-get install -y build-essential 

# install grafana helper tool wizzy to help with exporting dashboards
npm install -g wizzy

# install the python support libraries
sudo -H pip install -r requirements.txt

# set up the location for the files
if [[ ! -d /opt ]]; then
    sudo mkdir /opt
    sudo chmod 777 /opt
fi
if [[ ! -d /usr/local/src ]]; then
    sudo mkdir -p /usr/local/src
    sudo chmod 777 /usr/local/src
fi

version=1.1.4
whisper_version=${version}
carbon_version=${version}
graphite_version=${version}

# Checkout the master branches of Graphite, Carbon and Whisper and install from there
git clone -b ${graphite_version} --depth=1  https://github.com/graphite-project/graphite-web.git /usr/local/src/graphite-web
pushd /usr/local/src/graphite-web
pip install -r requirements.txt --no-cache-dir
python ./setup.py install
popd

git clone -b ${whisper_version} --depth=1  https://github.com/graphite-project/whisper.git /usr/local/src/whisper
pushd /usr/local/src/whisper
pip install -r requirements.txt --no-cache-dir
python ./setup.py install
popd

git clone -b ${carbon_version} --depth=1  https://github.com/graphite-project/carbon.git /usr/local/src/carbon
pushd /usr/local/src/carbon
pip install -r requirements.txt --no-cache-dir
python ./setup.py install
popd

# Install StatsD
statsd_version=master
git clone -b ${statsd_version} --depth=1  https://github.com/etsy/statsd.git /opt/statsd

# Install Grafana
mkdir  /opt/grafana
curl https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.3.0.linux-amd64.tar.gz -o /usr/local/src/grafana.tar.gz                                                                                  &&\
tar -xzf /usr/local/src/grafana.tar.gz -C /opt/grafana --strip-components=1
rm /usr/local/src/grafana.tar.gz

#-------------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------------

# Create a config file for statsd
cp conf/opt/statsd/config_*.js /opt/statsd/

# config graphite
cp  conf/opt/graphite/conf/*.conf /opt/graphite/conf/
cp  conf/opt/graphite/webapp/graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
mkdir -p /var/log/graphite
pushd /opt/graphite/webapp
PYTHONPATH=/opt/graphite/webapp /usr/local/opt/python/bin/django-admin.py collectstatic --noinput --settings=graphite.settings
popd

# config nginx
if [[ ! -d /usr/local/nginx/sites-enabled ]]; then
    mkdir /usr/local/nginx/sites-enabled
    chmod 777 /usr/local/nginx/sites-enabled
fi
if [[ -f /usr/local/nginx/sites-enabled/default ]]; then 
    rm /usr/local/nginx/sites-enabled/default
fi
cp conf/etc/nginx/nginx.conf /usr/local/nginx/conf/nginx.conf
cp conf/etc/nginx/sites-enabled/graphite-statsd.conf /usr/local/nginx/sites-enabled/graphite-statsd.conf

# init django admin
cp conf/usr/local/bin/django_admin_init.exp /usr/local/bin/django_admin_init.exp
cp conf/usr/local/bin/manage.sh /usr/local/bin/manage.sh
sudo chmod +x /usr/local/bin/manage.sh
/usr/local/bin/django_admin_init.exp

# Configure Grafana
cp conf/custom.ini /opt/grafana/conf/custom.ini

# Add the default datasource and dashboards
mkdir -p /dataload/datasources
mkdir -p /dataload/dashboards
cp conf/grafana/datasources/* /dataload/datasources
cp conf/grafana/dashboards/* /dataload/dashboards/
cp conf/grafana/manage-datasources-and-dashboards.sh /dataload

# set up the supervisor start script for grafana
sudo cp conf/supervisor-nginx.conf /etc/supervisor/conf.d/nginx.conf
sudo cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
sudo cp conf/supervisor-grafana.conf /etc/supervisor/conf.d/grafana.conf
sudo cp conf/run_grafana.sh /etc/supervisor/conf.d/run_grafana.sh
sudo chmod a+x /etc/supervisor/conf.d/run_grafana.sh
sudo cp conf/run_graphite.sh /etc/supervisor/conf.d/run_graphite.sh
sudo chmod a+x /etc/supervisor/conf.d/run_graphite.sh
sudo cp conf/supervisor-graphite.conf /etc/supervisor/conf.d/graphite.conf
sudo cp conf/supervisor-carbon.conf /etc/supervisor/conf.d/carbon.conf
sudo cp conf/supervisor-statsd.conf /etc/supervisor/conf.d/statsd.conf

#
# disable unused services
#
if [[ -f /etc/supervisor/conf.d/uwsgi.conf ]]; then
    sudo mv /etc/supervisor/conf.d/uwsgi.conf /etc/supervisor/conf.d/uwsgi.save
fi

# make sure the grafana shared directory is writable by the grafana owner
if [[ ! -d /usr/share/grafana ]]; then 
    sudo mkdir /usr/share/grafana
fi
sudo chmod 777 /usr/share/grafana

# cleanup
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

dcEndLog "install of app-specific web for 1213d64-stack (dcMonitoring)"
