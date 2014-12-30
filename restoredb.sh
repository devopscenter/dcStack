docker rm dbdata
RUNNING=$(docker inspect --format="{{ .State.ExitCode }}" dbdata 2> /dev/null)
if [ $? -eq 1 ]; then
    docker run -d -v /tmp/postgres/restore9.3 --name dbdata stack_restoredb echo Data-only container for postgres
fi 

docker rm db1
docker run -w /tmp --volumes-from dbdata -v /var/lib/postgresql/9.4/main --name db1 stack_restoredb /bin/bash -c /scripts/upgrade.sh
