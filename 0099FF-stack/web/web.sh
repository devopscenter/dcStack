#!/bin/bash -e

pushd /installs
sudo pip install -r requirements.txt

popd

echo "Installed customer-specific web and worker portion"
