#!/bin/bash

# Called at creation time for instances or containers (e.g. docker compose)


stripQuotes ()
{
    VAR_ORIG=$1
    # get rid of any quotes that may be around the string
    VAR_ORIG_TMP1="${VAR_ORIG%\"}"
    VAR_ORIG_TMP2="${VAR_ORIG_TMP1#\"}"

    VAR_ORIG_TMP3="${VAR_ORIG_TMP2%\'}"
    RET_NEW_VAR="${VAR_ORIG_TMP3#\'}"

    echo "${RET_NEW_VAR}"
}

# put the /etc/environment in the current env for this session...normally would have to log out and log in to get it.
while IFS='' read -r line || [[ -n "${line}" ]]
do
    if [[ "${line}" && "${line}" != "#"* ]]; then
        export "${line}"
    fi
done < /etc/environment

PT_SERVER=$(stripQuotes "${SYSLOG_SERVER}")
PT_PORT=$(stripQuotes "${SYSLOG_PORT}")
PT_PROTO=$(stripQuotes "${SYSLOG_PROTO}")

PAPERTRAIL_ADDRESS="${PT_SERVER}:${PT_PORT}"
echo "Papertrail destination -> " $PAPERTRAIL_ADDRESS

# Tell rsyslogd where to find papertrail
# filename starts with "95" so that it is the last config file loaded.
if [[ ! -f /etc/rsyslog.d/95-papertrail.conf ]]; then
    # check for lower case value
    if [[ "${PT_PROTO,,}" == "udp" ]]; then
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
