#!/bin/bash

BUCKET=$(cat /opt/elasticbeanstalk/config/ebenvinfo/envbucket)
FILE_DATE_STR=$(aws s3 ls s3://elasticbeanstalk-us-east-1-942939868497/cache/gem.tar.gz | awk {'print $1" "$2'})
FILE_DATE=$(date -d "$FILE_DATE_STR" +%s)
CURRENT_DATE=$(date --date '7 days ago' +%s)
if [[ -z "$FILE_DATE_STR" ]] || [[ $FILE_DATE -lt $CURRENT_DATE ]] ; then
  cd /var/app/current
  mkdir -p /tmp/cache
  tar -zcf /tmp/cache/gem.tar.gz vendor/bundle
  aws s3 cp /tmp/cache/gem.tar.gz s3://${BUCKET}/cache/gem.tar.gz
fi
exit 0
