#!/bin/sh
set -e

until nc -z "$MYSQL_HOST" 3306; do
  echo "[i] Waiting for MariaDB..."
  sleep 2
done

cd /var/www/html

if [ ! -f wp-config.php ]; then
  echo "[i] Installing WordPress..."
  wget https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
  tar -xzf /tmp/wp.tar.gz -C /tmp
  cp -r /tmp/wordpress/* .
  rm -rf /tmp/wordpress /tmp/wp.tar.gz
  cp wp-config-sample.php wp-config.php

  sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
  sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
  sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
  sed -i "s/localhost/${MYSQL_HOST}/" wp-config.php
fi

chown -R www-data:www-data /var/www/html

exec "$@"
