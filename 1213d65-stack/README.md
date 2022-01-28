1213d64-stack (dcMonitoring)
=====

Description: Basic monitoring instance.

Purpose:
This app-stack is intended to easily stand-up a monitoring instance in a standardized manner.
Support for the grafana web front end for the presentation and other tools as necessary to 
support monitoring

Configuration: web

Major Components:
python
node.js
virtualenv
grafana
health checks
pysnmp


Package details for the grafana install
- Installs binary to /usr/sbin/grafana-server
- Installs Init.d script to /etc/init.d/grafana-server
- Creates default file (environment vars) to /etc/default/grafana-server
- Installs configuration file to /etc/grafana/grafana.ini
- Installs systemd service (if systemd is available) name grafana-server.service
- The default configuration sets the log file at /var/log/grafana/grafana.log
- The default configuration specifies an sqlite3 db at /var/lib/grafana/grafana.db
- Installs HTML/JS/CSS and other Grafana files at /usr/share/grafana