#!/bin/bash -e

source VERSION
echo "Version=${dcSTACK_VERSION}"
source BASEIMAGE
echo "BaseImage=${baseimageversion}"

#replace variable dcSTACK_VERSION with the VERSION we are building
find . -name "Dockerfile" -type f -exec sed -i -e "s/dcSTACK_VERSION/$dcSTACK_VERSION/g" {} \;
find . -name "Dockerfile" -type f -exec sed -i -e "s~baseimageversion~$baseimageversion~g" {} \;
