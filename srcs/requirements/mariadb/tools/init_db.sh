#!/bin/bash
set -e

: "${MYSQL_DATABASE:?Need MYSQL_DATABASE env var}"
: "${MYSQL_USER:?Need MYSQL_USER env var}"
: "${MYSQL_PASSWORD:?Need MYSQL_PASSWORD env var}"

wait_for_mysql() {
  n=0
  until mysqladmin ping --silent; do
    n=$((n+1))
    if [ $n -ge 30 ]; then
      exit 1
    fi
    sleep 1
  done
}

if [ ! -d "/var/lib/mysql/mysql" ]; then
  mysqld --initialize-insecure --datadir=/var/lib/mysql --user=mysql
  chown -R mysql:mysql /var/lib/mysql
  mysqld_safe --datadir=/var/lib/mysql --skip-networking --pid-file=/var/run/mysqld/mysqld.pid &
  PID=$!
  wait_for_mysql
  mysql <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL
  if [ -n "${MYSQL_ROOT_PASSWORD:-}" ]; then
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"
  fi
  mysqladmin shutdown || kill -TERM "$PID" || true
fi

exec "$@"
