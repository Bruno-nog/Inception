FROM debian:11

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    php7.4 php7.4-fpm php7.4-mysql php7.4-curl php7.4-gd php7.4-mbstring php7.4-xml php7.4-zip \
    curl \
    mariadb-client \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /run/php


RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf


COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh


WORKDIR /var/www/html


ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm7.4", "-F"]
