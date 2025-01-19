#!/bin/bash
# BACKUP_FILE="./backup-$(date '+%Y-%m-%d-%H:%M:%S').gz"
mongodump --uri="${LOCAL_MONGODB_URI}" --gzip --archive="./backup.gz"
aws s3 mv ./backup.gz s3://wiz-demo-mongo-snapshots/backup-$(date '+%Y-%m-%d-%H:%M:%S').gz