#!/bin/bash -e

cp requirements.txt /installs/requirements.txt
cp requirements2.txt /installs/requirements2.txt
cp web.sh /installs/web.sh

sudo pip install -r requirements.txt

#
# Scipy and Sckit-learn must be installed AFTER numpy, in a separate pip install step
# (https://github.com/scikit-learn/scikit-learn/issues/4164#issuecomment-100391246)
# This also means that they cannot be built as wheels, so they are not in the normal requirements.txt file
# In order to ensure that wheels are not used, must use the --no-cache-dir option.
#
sudo pip install --no-cache-dir -r requirements2.txt

echo "Installed customer-specific web and worker portion"
