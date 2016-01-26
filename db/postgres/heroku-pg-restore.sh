#!/bin/bash

PROFILE="default"
DUMPFILE="init.dump"
DUMPID=""

function usage
{
  echo "usage: ./heroku-pg-restore.sh [--profile profile] [--dumpid heroku-dump-id] { --hostname ec2-instance-name | --publicip ec2-instance-public-ip } aws-keypair heroku-app-name"
}

if [[ -z $1 ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --profile )  shift
                 PROFILE=$1
                 ;;
    --dumpid )   shift
                 DUMPID=$1
                 ;;
    --hostname ) shift
                 HOST_NAME=$1
                 ;;
    --publicip ) shift
                 PUBLICIP=$1
                 ;;
    [!-]* )      if [[ $# -eq 2 ]]; then
                   LOCAL_KEYPAIR=$1
                   APPNAME=$2
                   shift; shift;
                 else
                   echo "Too many/few of the 2 required parameters."
                   usage
                   exit 1
                 fi
                 ;;
    * )          usage
                 exit 1
  esac
  shift
done

# grab the public ip address to use to SSH into the instance if hostname was provided instead
if [[ -z "$PUBLICIP" ]]; then
  PUBLICIP=$(aws --profile "${PROFILE}" ec2 describe-instances --filters "Name=tag:Name,Values=$HOST_NAME" --query 'Reservations[].Instances[].PublicIpAddress'|jq -r '.[]')
fi

# get the URL to pass to curl, then download a dump file
CURL_VAR=$(heroku pg:backups public-url $DUMPID -a $APPNAME -q)
curl "$CURL_VAR" -o "$DUMPFILE"

# upload the dump file to the ec2 instance, create the db, then restore
scp -i "$LOCAL_KEYPAIR" "$DUMPFILE" ubuntu@"${PUBLICIP}":~/.
ssh -i "$LOCAL_KEYPAIR" ubuntu@"${PUBLICIP}" "psql -U postgres -c 'create database $APPNAME'"
ssh -i "$LOCAL_KEYPAIR" ubuntu@"${PUBLICIP}" "pg_restore --verbose --clean --no-acl --no-owner -j 10 -U postgres -d $APPNAME $DUMPFILE"
