FROM alpine:3.6

RUN apk update
RUN apk --no-cache add \
    ca-certificates \
    curl \
    php5-bcmath \
    php5-curl \
    php5-fpm \
    php5-gd \
    php5-json \
    php5-ldap \
    php5-pcntl \
    php5-pdo_mysql \
    php5-snmp \
    && sed -i \
    -e 's|^listen =.*$|listen = 9000|' \
    -e 's|^;daemonize =.*$|daemonize = no|' \
    /etc/php5/php-fpm.conf

EXPOSE 9000
CMD ["/usr/bin/php-fpm5"]
