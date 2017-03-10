#!/bin/bash -e
CUST_APP_NAME=$1
ENV=$2

#-------------------------------------------------------------------------------
# run the appliction specific web_commands.sh 
#-------------------------------------------------------------------------------
if [[ -e "${HOME}/${CUST_APP_NAME}/${CUST_APP_NAME}-utils/config/${ENV}/web-commands.sh" ]]; then
    sudo "${HOME}/${CUST_APP_NAME}/${CUST_APP_NAME}-utils/config/${ENV}/web-commands.sh"
fi

cp requirements.txt /installs/requirements.txt
cp requirements2.txt /installs/requirements2.txt
cp web.sh /installs/web.sh

sudo pip install -r requirements.txt

#
# Scipy and Sckit-learn must be installed AFTER numpy, in a separate pip install step
# (https://github.com/scikit-learn/scikit-learn/issues/4164#issuecomment-100391246)
# This also means that they cannot be built as wheels, so they are not in the normal requirements.txt file
#
sudo pip install -r requirements2.txt

echo "Installed customer-specific web and worker portion"
