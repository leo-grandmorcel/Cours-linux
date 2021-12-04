#!/bin/bash
# Simple script that archives the file /var/www/nextcloud into /srv/backup.
# Leo Grand-Morcel

name=("/srv/backup/nexcloud_$(date +"%y%m%d_%H%m%S").tar.gz")
cd /var/www/
/usr/bin/tar -czvf "$name" nextcloud/ &> /dev/null

# Prompt success
echo "Backup "$name" created successfully."

# Write in logfile
log_prefix=$(date +"[%y/%m/%d %H:%m:%S]")
log_line="${log_prefix} Backup "$name" created successfully."
echo "${log_line}" >> /var/log/backup/backup.log
