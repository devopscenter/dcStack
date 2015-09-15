#!/bin/bash

sudo pip install virtualenv
mkdir update
cd update/
virtualenv venv
source venv/bin/activate
cp ../requirements.txt .
pip install -r requirements.txt 
pip list --outdated

