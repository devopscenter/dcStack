from fabric.api import run, task, local, env
from django_code_deploy import fabfile as deploy

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
    run("~/dcStack/db/postgres-restore/download-pgdump-backup.sh %s %s" %
        (s3_bucket_host, db_name))


@task
def restore_pgdump_backup(db_name):
    run("~/dcStack/db/postgres-restore/restore-pgdump-backup.sh %s" %
        (db_name))


@task
def restore_pgdump_backup_schema_only(db_name):
    run("~/dcStack/db/postgres-restore/restore-pgdump-backup.sh --schema-only %s" % (db_name))


# @task
# def db_migrate():
#    run("cd /data/deploy/current && python manage.py migrate")
