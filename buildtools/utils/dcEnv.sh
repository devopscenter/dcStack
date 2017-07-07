#!/bin/bash - 
#===============================================================================
#
#          FILE: dcEnv.sh
# 
#         USAGE: ./dcEnv.sh 
# 
#   DESCRIPTION: script to include in other scripts that set up the environment
#                and provides some basic utility functions
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 03/21/2017 12:02:46
#      REVISION:  ---
#===============================================================================

#set -o nounset                              # Treat unset variables as an error

GOOGLE_DIR=$(find $HOME -maxdepth 1 -type d -name Googl*)

dcLog()
{
    msg=$1
    state=$2

    scriptName=$(basename -- "$0")
    TIMESTAMP=$(date +%F_%T)

    if [[ ! -z ${state} ]]; then
        echo "[${TIMESTAMP}]:${scriptName}:${state}:${msg}"
    else
        echo "[${TIMESTAMP}]:${scriptName}::${msg}"
    fi
}

dcStartLog()
{
    msg=$1
    dcLog "${msg}" "START"
}

dcEndLog()
{
    msg=$1
    dcLog "${msg}" "END"
}

dcTrackEvent()
{
    CUSTOMER_NAME=$1
    CUSTOMER_APP_NAME=$2
    EVENT=$3
    MSG=$4
    if [[ -n ${GOOGLE_DIR} ]]; then
        TRACKING_FILE="${GOOGLE_DIR}/devops.center/monitoring/dcEventTracking.txt"

        if [[ ! -f ${TRACKING_FILE} ]]; then
            dcLog "ERROR: $TRACKING_FILE not found, the event will not be written"
        else
            TIMESTAMP=$(date +%F_%T)
            JSONTOWRITE="{\"date\": \"${TIMESTAMP}\", \"customer\": \"${CUSTOMER_NAME}\", \"instancename\": \"${CUSTOMER_APP_NAME}\", \"event\": \"${EVENT}\", \"msg\": \"${MSG}\"} "
            echo "${JSONTOWRITE}" >> "${TRACKING_FILE}"
        fi
    else
        echo "Could not save event, file not available"
    fi
}
