#!/bin/bash -e

BUCKET_NAME=$1

TIMESTAMP=$(date +%F_%T | tr ':' '-')
YEAR=$(date +%Y)
MONTH=$(date +%m)
S3_FILE="${BUCKET_NAME}/${HOSTNAME}/${YEAR}/${MONTH}/jenkins.tar.gz-${TIMESTAMP}"

# create temporary tar file
JENKINS_BACKUP_FILE=$(mktemp /tmp/jenkins.tar.gz.XXXXX)

# create s3 bucket if it doesn't already exist
/usr/local/bin/s3cmd mb "s3://${BUCKET_NAME}"

# tar both jenkins directories
sudo tar czvf "$JENKINS_BACKUP_FILE" /media/data/jenkins /var/lib/jenkins

# upload to s3
/usr/local/bin/s3cmd put "$JENKINS_BACKUP_FILE" "s3://${S3_FILE}"

# remove temporary file
if [[ -f "$JENKINS_BACKUP_FILE" ]]; then
  rm "$JENKINS_BACKUP_FILE"
fi
