#!/bin/bash
BACKUP_FILE="./backup-$(date '+%Y-%m-%d-%H:%M:%S').gz"
mongodump --uri="${LOCAL_MONGODB_URI}" --gzip --archive=${BACKUP_FILE}
aws s3 cp ${BACKUP_FILE} s3://wiz-demo-mongo-snapshots
rm ${BACKUP_FILE}