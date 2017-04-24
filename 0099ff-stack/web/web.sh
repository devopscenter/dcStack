#!/bin/bash -e

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific web for 0099ff"

sudo pip install -r requirements.txt

dcEndLog "install of app-specific web for 0099ff"
