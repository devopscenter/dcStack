# ==============================================================================
#
#          FILE: fabfile.py
#
#         USAGE: fabfile.py
#
#   DESCRIPTION: customer appName specific that will drop the indexes identified
#                by the CREATE INDEX lines in the customer appname .sql file
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Gregg Jensen (), gjensen@devops.center
#                Bob Lozano (), bob@devops.center
#  ORGANIZATION: devops.center
#       CREATED: 11/21/2016 15:13:37
#      REVISION:  ---
#
# Copyright 2014-2017 devops.center llc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ==============================================================================

from fabric.api import run, task, local, env, sudo 
from dcCodeDeploy import dcCodeDeploy as deploy

env.user = "ubuntu"


@task
def start_test_stop(instance_id, s3_bucket_host, db_name):
    start_host(instance_id)
    download_pgdump_backup(s3_bucket_host, db_name)
    restore_pgdump_backup(db_name)
    stop_host(instance_id)


@task
def start_test_schema_stop(instance_id, s3_bucket_host, db_name):
    start_host(instance_id)
    download_pgdump_backup(s3_bucket_host, db_name)
    restore_pgdump_backup_schema_only(db_name)
    stop_host(instance_id)


@task
def start_host(instance_id):
    local("/usr/local/bin/aws ec2 start-instances --instance-ids %s" %
          (instance_id))
    local("/usr/local/bin/aws ec2 wait instance-running --instance-ids %s" %
          (instance_id))


@task
def stop_host(instance_id):
    local("/usr/local/bin/aws ec2 stop-instances --instance-ids %s" %
          (instance_id))
    local("/usr/local/bin/aws ec2 wait instance-stopped --instance-ids %s" %
          (instance_id))


@task
def install_postgres(private_ip, papertrail_address, vpc_cidr, database,
                     s3_backup_bucket, s3_wale_bucket, pgversion):
    run("./new_postgres.sh %s %s %s %s %s %s %s" % (private_ip,
                                                    papertrail_address,
                                                    vpc_cidr, database,
                                                    s3_backup_bucket,
                                                    s3_wale_bucket,
                                                    pgversion))
    # run("~/dcStack/db/postgres/new_postgres.sh %s %s %s %s %s %s %s" %
    # (private_ip, papertrail_address, vpc_cidr, database, s3_backup_bucket,
    # s3_wale_bucket, pgversion))


@task
def download_pgdump_backup(s3_bucket_host, db_name):
    run("cd /media/data/db_restore/ && ./download.sh %s %s" %
        (s3_bucket_host, db_name))


@task
def restore_pgdump_backup(db_name, num="1"):
    run("cd /media/data/db_restore/ && ./restore.sh %s --num %s" %
        (db_name, num))


@task
def restore_pgdump_backup_schema_only(db_name):
    run("~/dcStack/db/postgres-restore/restore-pgdump-backup.sh --schema-only %s" % (db_name))


# @task
# def db_migrate():
#    run("cd /data/deploy/current && python manage.py migrate")

@task
def cleanup_pgdump_backup(db_name):
    sudo("cd /media/data/db_restore/ &&  rm %s.sql.gz-*" % (db_name) )
