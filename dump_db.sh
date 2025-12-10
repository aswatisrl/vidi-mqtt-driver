#!/bin/bash
mkdir -p ./backup_db
DOM=$(date +%d)
backup_dir=./backup_db/$(date +'%Y-%m-%d').sql
compressed=${backup_dir}.gz
docker exec mysql sh -c 'exec mysqldump --all-databases --events -uroot -p"$MYSQL_ROOT_PASSWORD"' > ${backup_dir}
rm -f ${compressed}
gzip $backup_dir
find ./backup_db -type f -mtime +28 -delete
