#!/bin/bash

BACKUP_DIR="/home/ubuntu/mysql_backups"
DB_USER="root"
DB_PASS="1234"
DATE=$(date +%F_%H-%M-%S)

mkdir -p "$BACKUP_DIR"

echo "Starting MySQL Backup..."

mysqldump -u"$DB_USER" -p"$DB_PASS" --all-databases > "$BACKUP_DIR/all_db_$DATE.sql"

echo "Backup successfully completed"

