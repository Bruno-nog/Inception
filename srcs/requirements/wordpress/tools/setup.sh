#!/bin/bash
set -e

if [ ! -f wp-config.php ]; then
    echo "[i] Downloading WordPress..."
    curl -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mv wordpress/* .
    rm -rf wordpress latest.tar.gz

    echo "[i] Creating wp-config.php..."
    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/$MYSQL_DATABASE/" wp-config.php
    sed -i "s/username_here/$MYSQL_USER/" wp-config.php
    sed -i "s/password_here/$MYSQL_PASSWORD/" wp-config.php
    sed -i "s/localhost/$MYSQL_HOST/" wp-config.php
fi

exec "$@"
