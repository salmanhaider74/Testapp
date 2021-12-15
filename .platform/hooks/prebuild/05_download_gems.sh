#!/bin/bash

BUCKET=$(cat /opt/elasticbeanstalk/config/ebenvinfo/envbucket)
mkdir -p /tmp/cache
if aws s3 ls s3://${BUCKET}/cache/gem.tar.gz ; then
  aws s3 cp --quiet s3://${BUCKET}/cache/gem.tar.gz /tmp/cache/gem.tar.gz
  cd /var/app/staging && tar -xf /tmp/cache/gem.tar.gz
fi
exit 0
