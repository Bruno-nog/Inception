#!/bin/bash
set -e

unset MYSQL_HOST

: "${MYSQL_DATABASE:?Need MYSQL_DATABASE env var}"
: "${MYSQL_USER:?Need MYSQL_USER env var}"
: "${MYSQL_PASSWORD:?Need MYSQL_PASSWORD env var}"

SOCKET=/var/run/mysqld/mysqld.sock
DATADIR=/var/lib/mysql

if [ ! -d "${DATADIR}/${MYSQL_DATABASE}" ]; then
    echo "[i] Initializing MariaDB data directory"

    if command -v mariadb-install-db >/dev/null 2>&1; then
        mariadb-install-db --user=mysql --datadir="${DATADIR}"
    elif command -v mysql_install_db >/dev/null 2>&1; then
        mysql_install_db --user=mysql --datadir="${DATADIR}"
    else
        mysqld --initialize-insecure --datadir="${DATADIR}" --user=mysql || true
    fi

    chown -R mysql:mysql "${DATADIR}"
    chown -R mysql:mysql /var/run/mysqld

    echo "[i] Starting temporary MariaDB server for initialization..."
    mysqld --user=mysql \
           --datadir="${DATADIR}" \
           --socket="${SOCKET}" \
           --skip-networking \
           --pid-file=/var/run/mysqld/mysqld.pid &

    PID=$!

    echo "[. ] Waiting for socket file..."
    n=0
    until [ -S "${SOCKET}" ]; do
        n=$((n+1))
        if [ "$n" -ge 30 ]; then
            echo "[!] Socket did not appear"
            kill -TERM "$PID" 2>/dev/null || true
            exit 1
        fi
        sleep 0.5
    done

    echo "[. ] Waiting for MariaDB to respond..."
    n=0
    until mysqladmin --socket="${SOCKET}" --protocol=socket -uroot ping >/dev/null 2>&1; do
        n=$((n+1))
        if [ "$n" -ge 60 ]; then
            echo "[!] MariaDB did not start in time"
            kill -TERM "$PID" 2>/dev/null || true
            exit 1
        fi
        sleep 1
    done

    echo "[i] Creating database and user..."
    mysql --socket="${SOCKET}" --protocol=socket -uroot <<EOSQL
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost'
  IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%'
  IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOSQL

    if [ -n "${MYSQL_ROOT_PASSWORD:-}" ]; then
        echo "[i] Setting root password..."
        mysql --socket="${SOCKET}" --protocol=socket -uroot <<EOSQL
ALTER USER 'root'@'localhost'
  IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOSQL
    fi

    echo "[i] Shutting down temporary server..."
    mysqladmin --socket="${SOCKET}" --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown || true

    wait "$PID" 2>/dev/null || true
    echo "[i] MariaDB initialization finished"
else
    echo "[i] MariaDB already initialized, skipping database creation"
fi

echo "[i] Starting MariaDB server..."
exec mysqld --user=mysql
