FROM adhocore/phpfpm:8.0

MAINTAINER Jitendra Adhikari <jiten.adhikary@gmail.com>

ENV ADMINER_VERSION=4.7.8
ENV ALPINE_VERSION=3.6

RUN \
  # install
  apk add -U --no-cache \
    mysql mysql-client \
    nano \
    git \
    nginx \
    redis \
    supervisor \
    nodejs \
    npm \
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

    RUN echo "http://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VERSION/main" >> /etc/apk/repositories
    RUN echo "http://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VERSION/community" >> /etc/apk/repositories
    RUN apk update
    RUN apk add mongodb \
                mongodb-tools

# create mongodb directory
RUN mkdir -p /data/db

# nginx config
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# resource
COPY php/* /var/www/html/

# supervisor config
COPY \
  mysql/mysqld.ini \
  nginx/nginx.ini \
  php/php-fpm.ini \
  redis/redis-server.ini \
    /etc/supervisor.d/


# setup npm
RUN npm install -g npm@latest

RUN npm install

# include your other npm run scripts e.g npm rebuild node-sass

# run your default build command here mine is npm run prod
RUN npm run prod


# entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# ports
EXPOSE 80 3306 9000 6379 27017

# commands
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
