#!/bin/sh

# Tenta conectar de verdade usando as credenciais
while ! mariadb -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; do
    echo "[i] Aguardando MariaDB em $MYSQL_HOST com credenciais..."
    sleep 2
done

echo "[i] Conectado com sucesso!"

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "[i] Installing WordPress..."
    # Usando wp-cli para baixar e configurar (mais seguro)
    wp core download --allow-root
    
    wp config create --allow-root \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=$MYSQL_HOST

    wp core install --allow-root \
        --url=$DOMAIN_NAME \
        --title=$WP_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL
fi

chown -R www-data:www-data /var/www/html

echo "[i] WordPress is ready!"
exec "$@"
