mkdir -p tools
cat > tools/init_db.sh <<'EOF'
#!/bin/bash
set -e

# Se nenhuma variável está definida, falha rápido (evita criar DB sem dados)
: "${MYSQL_DATABASE:?Need MYSQL_DATABASE env var}"
: "${MYSQL_USER:?Need MYSQL_USER env var}"
: "${MYSQL_PASSWORD:?Need MYSQL_PASSWORD env var}"

# Função para aguardar o servidor MySQL estar pronto
wait_for_mysql() {
  n=0
  until mysqladmin ping --silent; do
    n=$((n+1))
    if [ $n -ge 30 ]; then
      echo "[!] mariadb did not start in time"
      exit 1
    fi
    sleep 1
  done
}

# Inicializar data dir se necessário
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "[i] Initializing MariaDB data directory"
  mysqld --initialize-insecure --datadir=/var/lib/mysql --user=mysql

  chown -R mysql:mysql /var/lib/mysql

  # start temporary server (no networking for safety)
  mysqld_safe --datadir=/var/lib/mysql --skip-networking --pid-file=/var/run/mysqld/mysqld.pid &
  PID=$!

  # wait until mysql ready
  wait_for_mysql

  # criar DB e usuário usando variáveis de ambiente
  mysql <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

  # se quiser setar root password (opcional)
  if [ -n "${MYSQL_ROOT_PASSWORD:-}" ]; then
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"
  fi

  # shutdown temporary server (mysqladmin pode falhar, mas tentamos)
  mysqladmin shutdown || kill -TERM "$PID" || true

  echo "[i] MariaDB initialization finished"
else
  echo "[i] MariaDB already initialized, skipping database creation"
fi

# Exec do comando final (repassa para CMD)
exec "$@"
EOF

# permissions
chmod +x tools/init_db.sh
