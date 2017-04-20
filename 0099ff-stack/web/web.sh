#!/bin/bash -e

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific web for 0099ff"

cp requirements.txt /installs/requirements.txt
cp requirements2.txt /installs/requirements2.txt
cp web.sh /installs/web.sh

sudo pip install -r requirements.txt

dcEndLog "install of app-specific web for 0099ff"
