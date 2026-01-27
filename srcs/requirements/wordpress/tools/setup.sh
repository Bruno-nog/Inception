#!/bin/sh
set -e

# Wait for MariaDB to be reachable.
echo "[i] Waiting for MariaDB to be available at ${MYSQL_HOST:-mariadb}..."
# Try multiple strategies: mysqladmin ping (no creds), mysqladmin ping as root, mysql -e as app user
n=0
until \
  mysqladmin ping -h"${MYSQL_HOST}" --silent >/dev/null 2>&1 || \
  ( [ -n "${MYSQL_ROOT_PASSWORD:-}" ] && mysqladmin ping -h"${MYSQL_HOST}" -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent >/dev/null 2>&1 ) || \
  ( [ -n "${MYSQL_USER:-}" ] && [ -n "${MYSQL_PASSWORD:-}" ] && mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1 ); do
    n=$((n+1))
    if [ "$n" -ge 120 ]; then
      echo "[!] MariaDB did not become available in time"
      exit 1
    fi
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
