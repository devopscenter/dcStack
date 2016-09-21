#!/bin/bash -e

#pushd /installs
sudo pip install -r requirements.txt

#
# Scipy and Sckit-learn must be installed AFTER numpy, in a separate pip install step
# (https://github.com/scikit-learn/scikit-learn/issues/4164#issuecomment-100391246)
# This also means that they cannot be built as wheels, so they are not in the normal requirements.txt file
#
sudo pip install -r requirements2.txt

#popd

echo "Installed customer-specific web and worker portion"
