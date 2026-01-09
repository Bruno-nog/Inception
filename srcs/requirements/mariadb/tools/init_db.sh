#!/bin/bash
set -e

: "${MYSQL_DATABASE:?Need MYSQL_DATABASE env var}"
: "${MYSQL_USER:?Need MYSQL_USER env var}"
: "${MYSQL_PASSWORD:?Need MYSQL_PASSWORD env var}"

SOCKET=/var/run/mysqld/mysqld.sock
DATADIR=/var/lib/mysql

wait_for_mysql() {
  n=0
  until mysql --protocol=socket -uroot -e "SELECT 1" >/dev/null 2>&1; do
    n=$((n+1))
    if [ $n -ge 60 ]; then
      echo "[!] mariadb did not start in time"
      return 1
    fi
    sleep 1
  done
  return 0
}

if [ ! -d "${DATADIR}/mysql" ]; then
  echo "[i] Initializing MariaDB data directory"

  if command -v mariadb-install-db >/dev/null 2>&1; then
    mariadb-install-db --user=mysql --datadir="${DATADIR}"
  elif command -v mysql_install_db >/dev/null 2>&1; then
    mysql_install_db --user=mysql --datadir="${DATADIR}"
  else
    mysqld --initialize-insecure --datadir="${DATADIR}" --user=mysql || true
  fi

  chown -R mysql:mysql "${DATADIR}"

  # Start temporary server (no networking)
  mysqld --datadir="${DATADIR}" --socket="${SOCKET}" --skip-networking --skip-networking=0 --pid-file=/var/run/mysqld/mysqld.pid &
  PID=$!

  # Wait for it to accept socket connections
  if ! wait_for_mysql; then
    echo "[!] mysql did not become available"
    kill -TERM "$PID" || true
    exit 1
  fi

  # Create DB and user
  mysql --protocol=socket -uroot <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

  if [ -n "${MYSQL_ROOT_PASSWORD:-}" ]; then
    mysql --protocol=socket -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"
  fi

  # Shutdown temporary server
  mysqladmin --protocol=socket -uroot shutdown || kill -TERM "$PID" || true

  echo "[i] MariaDB initialization finished"
else
  echo "[i] MariaDB already initialized, skipping database creation"
fi

exec mysqld --user=mysql
