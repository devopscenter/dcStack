#!/bin/bash -e

source /usr/local/bin/dcEnv.sh                       # initalize logging environment
dcStartLog "install of app-specific worker for 000000"

sudo pip install -r requirements.txt

dcEndLog "install of app-specific worker for 000000"
