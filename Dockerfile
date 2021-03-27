FROM adhocore/phpfpm:8.0

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV \
  ADMINER_VERSION=4.7.8

RUN \
  # install
  apk add -U --no-cache \
    memcached \
    mysql mysql-client \
    nano \
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

# mailcatcher
COPY --from=tophfr/mailcatcher /usr/lib/libruby.so.2.5 /usr/lib/libruby.so.2.5
COPY --from=tophfr/mailcatcher /usr/lib/ruby/ /usr/lib/ruby/
COPY --from=tophfr/mailcatcher /usr/bin/ruby /usr/bin/mailcatcher /usr/bin/

# resource
COPY php/index.php /var/www/html/index.php

# supervisor config
COPY \
  mail/mailcatcher.ini \
  memcached/memcached.ini \
  mysql/mysqld.ini \
  nginx/nginx.ini \
  php/php-fpm.ini \
  redis/redis-server.ini \
    /etc/supervisor.d/

# entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# ports
EXPOSE 11211 9000 6379 3306 88 80

# commands
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
