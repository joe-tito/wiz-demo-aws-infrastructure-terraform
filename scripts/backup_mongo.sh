#!/bin/bash

DATE=$(date '+%Y-%m-%d-%H:%M:%S')
BACKUP_FILE="backup-${DATE}.gz"

mongodump --uri="${LOCAL_MONGODB_URI}" --gzip --archive="${BACKUP_FILE}"