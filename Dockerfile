FROM adhocore/phpfpm:8.0

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV \
  ADMINER_VERSION=4.7.8

RUN \
  # install
  apk add -U --no-cache \
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
  
### MongoDB
   RUN set -x && \
       apk update && \
       apk add \
    	   bzip2 \
    	   xz
           
    RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.6/main' >> /etc/apk/repositories
    RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.6/community' >> /etc/apk/repositories
    RUN apk update
    RUN apk add mongodb \
                mongodb-tools

# create mongodb directory
RUN mkdir -p /data/db
COPY mongo/admin.js /data/admin.js

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
EXPOSE 80 3306 9000 6379 27017

# commands
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
