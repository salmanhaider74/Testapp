#!/bin/bash

if [ ! -f /usr/local/bin/remote_syslog ]; then
  cd /tmp
  wget https://github.com/papertrail/remote_syslog2/releases/download/v0.20/remote_syslog_linux_amd64.tar.gz
  tar -xzf remote_syslog_linux_amd64.tar.gz
  cp /tmp/remote_syslog/remote_syslog /usr/local/bin
  /sbin/chkconfig remote_syslog on
fi

cp /var/app/staging/.platform/rsyslog/remote_syslog /etc/init.d/remote_syslog
cp /var/app/staging/.platform/rsyslog/log_files.yml /etc/log_files.yml
INSTANCE_ID=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
HOST_NAME=${RAILS_ENV}_${INSTANCE_ID}
sed "s/hostname:.*/hostname: $HOST_NAME/" -i /etc/log_files.yml

/sbin/service remote_syslog restart