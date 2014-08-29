#!/bin/bash -e

source VERSION
echo "Version=${devops_version}"

find . -name "Dockerfile" -type f -exec sed -i -e "s/$devops_version/devops_version/g" {} \;
