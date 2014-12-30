rm -rf /var/lib/postgresql/9.4/main/*
/usr/lib/postgresql/9.4/bin/initdb --locale en_US.UTF-8 -D /var/lib/postgresql/9.4/main
cp /etc/postgresql/9.4/main/postgresql.conf /var/lib/postgresql/9.4/main/postgresql.conf
/usr/lib/postgresql/9.4/bin/pg_upgrade  -b /usr/lib/postgresql/9.3/bin -B /usr/lib/postgresql/9.4/bin -d /tmp/postgres/restore9.3 -D /var/lib/postgresql/9.4/main
