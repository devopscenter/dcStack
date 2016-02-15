#!/bin/bash

# remove cron entry for backup, if it exists
if (sudo crontab -l -u postgres|grep '^[^#].*pg_backup_rotated\.sh\b.*'); then
  sudo sed -i 's/^[^#].*pg_backup_rotated\.sh\b.*/#&/g' /var/spool/cron/crontabs/postgres
else
  echo "Backup not enabled.  No changes made."
fi
