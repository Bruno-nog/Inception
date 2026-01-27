FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld /var/lib/mysql \
  && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql \
  && chmod 777 /var/run/mysqld

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/99-inception.cnf
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

VOLUME ["/var/lib/mysql"]

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init_db.sh"]
CMD ["mysqld"]
