FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    php php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-zip \
    curl \
    mariadb-client \
    wget \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm8.2", "-F"]
