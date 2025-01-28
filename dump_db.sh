#!/bin/bash
DOM=$(date +%d)
backup_dir=/opt/nbiot-server/backup_db/$(date +'%Y-%m-%d').sql
docker exec mysql sh -c 'exec mysqldump --all-databases --events -uroot -p"$MYSQL_ROOT_PASSWORD"' > ${backup_dir}
gzip $backup_dir
find /opt/nbiot-server/backup_db -type f -mtime +28 -delete



