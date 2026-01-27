FROM debian:11


ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /etc/nginx/certs


COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY tools/setup.sh /usr/local/bin/setup.sh


RUN chmod +x /usr/local/bin/setup.sh


EXPOSE 443


ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["nginx", "-g", "daemon off;"]
