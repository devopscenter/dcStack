from fabric.api import *

env.user = "ubuntu"

@task
def download_pgdump_backup(s3_bucket_host,db_name):
  run("cd ~/docker-stack && git pull origin hotfix/pgrestore-separation")
  run("~/docker-stack/db/postgres-restore/download-pgdump-backup.sh %s %s" % (s3_bucket_host, db_name))

@task
def restore_pgdump_backup(backup_file,db_name):
  run("cd ~/docker-stack && git pull origin hotfix/pgrestore-separation")
  run("~/docker-stack/db/postgres-restore/restore-pgdump-backup.sh %s %s" % (backup_file, db_name))

#@task
#def db_migrate():
#  run("cd /data/deploy/current && python manage.py migrate")
