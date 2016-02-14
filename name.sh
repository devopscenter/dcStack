#!/bin/bash -ev

source VERSION
echo "Version=${devops_version}"
source BASEIMAGE
echo "BaseImage=${baseimageversion}"

#replace variable devops_version with the VERSION we are building
find . -name "Dockerfile" -type f -exec sed -i -e "s/devops_version/$devops_version/g" {} \;
find . -name "Dockerfile" -type f -exec sed -i -e "s~baseimageversion~$baseimageversion~g" {} \;
