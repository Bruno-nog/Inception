FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip \
    curl \
    mariadb-client \
    wget \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# --- O QUE ESTAVA FALTANDO: Instalação do WP-CLI ---
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php && chown www-data:www-data /run/php

# Ajuste do PHP-FPM para ouvir na porta 9000
RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www/html

# Garante que a pasta pertença ao usuário do servidor web
RUN chown -R www-data:www-data /var/www/html

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm8.2", "-F"]
