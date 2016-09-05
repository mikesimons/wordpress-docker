#!/bin/sh

config_file=/etc/nginx/nginx.conf

sed -i \
  -e "s/WORKER_PROCS/$(nproc)/g" \
  $config_file

exec nginx