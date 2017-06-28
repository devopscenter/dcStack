ab0000-stack (Jenkins)
=====

Description: Basic Jenkins instance.

Purpose:
This app-stack is intended to easily stand-up a Jenkins instance in a standardized manner.
Support is included for local pre-commit processing (grunt, python), though not particularly
counting on a db instance. This includes a backup facility which writes to an s3 bucket.

Configuration: web

Major Components:
jenkins
python
grunt
node.js
virtualenv

