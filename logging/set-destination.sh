#!/bin/bash

# Called at creation time for instances or containers (e.g. docker compose)

# put the /etc/environment in the current env for this session...normally would have to log out and log in to get it.
while IFS='' read -r line || [[ -n "${line}" ]]
do
	if [[ "${line}" && "${line}" != "#"* ]]; then
		export "${line}"
	fi
done < /etc/environment


PAPERTRAIL_ADDRESS="${SYSLOG_SERVER}:${SYSLOG_PORT}"
echo "Papertrail destination -> " $PAPERTRAIL_ADDRESS

# Tell rsyslogd where to find papertrail
# filename starts with "95" so that it is the last config file loaded.
if [[ ! -f /etc/rsyslog.d/95-papertrail.conf ]]; then
    # check for lower case value
    if [[ "${SYSLOG_PROTO,,}" == "udp" ]]; then
        echo "*.* @${PAPERTRAIL_ADDRESS}" | sudo tee /etc/rsyslog.d/95-papertrail.conf > /dev/null
    else
        # they have chose tcp or anything else
        echo "*.* @@${PAPERTRAIL_ADDRESS}" | sudo tee /etc/rsyslog.d/95-papertrail.conf > /dev/null
    fi
fi

# restart rsyslog, in order to utilize new config
sudo /etc/init.d/rsyslog restart

# Finally, restart rsyslogd and supervisor
sudo /etc/init.d/supervisor restart
