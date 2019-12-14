FROM adhocore/phpfpm:7.4

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV ADMINER_VERSION=4.7.5
ENV MAILCATHCHER_VERSION=0.7.1

# nano
RUN apk add -U nano

# mysql
RUN apk add mysql mysql-client

# pgsql
RUN apk add postgresql

# redis
RUN apk add redis

# nginx
RUN \
  addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
    && apk add nginx

# supervisor
RUN apk add supervisor

# supervisor config
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY mysql/mysqld.ini nginx/nginx.ini php/php-fpm.ini pgsql/postgres.ini mail/mailcatcher.ini redis/redis-server.ini /etc/supervisor.d/
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# adminer
RUN \
  mkdir -p /var/www/adminer \
  && curl -sSLo /var/www/adminer/index.php "https://github.com/vrana/adminer/releases/download/v$ADMINER_VERSION/adminer-$ADMINER_VERSION-en.php"

# mailcatcher
COPY --from=tophfr/mailcatcher:$MAILCATHCHER_VERSION /usr/lib/libruby.so.2.5 /usr/lib/libruby.so.2.5
COPY --from=tophfr/mailcatcher:$MAILCATHCHER_VERSION /usr/lib/ruby/ /usr/lib/ruby/
COPY --from=tophfr/mailcatcher:$MAILCATHCHER_VERSION /usr/bin/ruby /usr/bin/mailcatcher /usr/bin/

# resource
COPY php/index.php /var/www/html/index.php

# entrypoint
RUN chmod +x /docker-entrypoint.sh

# cleanup
RUN \
  rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

EXPOSE 9000 6379 5432 3306 88 80

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
