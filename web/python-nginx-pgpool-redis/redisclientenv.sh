#!/bin/bash -ev

REDIS_VERSION=3.0.7

WHEELHOUSE=/wheelhouse
PIP_WHEEL_DIR=/wheelhouse
PIP_FIND_LINKS=/wheelhouse

echo "WHEELHOUSE=/wheelhouse" | sudo tee -a /etc/environment
echo "PIP_WHEEL_DIR=/wheelhouse" | sudo tee -a /etc/environment
echo "PIP_FIND_LINKS=/wheelhouse" | sudo tee -a /etc/environment
