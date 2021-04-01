FROM adhocore/phpfpm:8.0

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV \
  ADMINER_VERSION=4.7.8

RUN \
  # install
  apk add -U --no-cache \
    mysql mysql-client \
    nano \
    git \
    nginx \
    redis \
    supervisor \
  # adminer
  && mkdir -p /var/www/adminer \
    && curl -sSLo /var/www/adminer/index.php \
      "https://github.com/vrana/adminer/releases/download/v$ADMINER_VERSION/adminer-$ADMINER_VERSION-en.php" \
  # cleanup
  && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

# nginx config
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# resource
COPY php/index.php /var/www/html/index.php

# supervisor config
COPY \
  mysql/mysqld.ini \
  nginx/nginx.ini \
  php/php-fpm.ini \
  redis/redis-server.ini \
    /etc/supervisor.d/

# entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# ports
EXPOSE 80 3306 9000 6379

# commands
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
