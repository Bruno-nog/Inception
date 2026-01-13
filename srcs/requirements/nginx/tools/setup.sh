#!/bin/bash
set -e

CERT=/etc/nginx/certs/inception.crt
KEY=/etc/nginx/certs/inception.key

if [ ! -f "$CERT" ]; then
  echo "[i] Generating SSL certificate"
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$KEY" \
    -out "$CERT" \
    -subj "/C=BR/ST=SP/L=SP/O=42/OU=Inception/CN=localhost"
fi

exec "$@"
