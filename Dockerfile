# Offical Docker PHP & Apache image https://hub.docker.com/_/php/
# To do: fix compatiability with php 7
FROM php:5.6-apache

# Install deps
RUN apt-get update && apt-get install -y \
              libcurl4-gnutls-dev \
              php5-curl \
              php5-json \
              php5- mcrypt \
              php5-mysql \
              libmcrypt-dev \
              git-core

# Enable PHP modules
RUN docker-php-ext-install -j$(nproc) mysql mysqli curl json mcrypt gettext
RUN pecl install redis-2.2.8 \
  \ && docker-php-ext-enable redis

RUN a2enmod rewrite

# Add custom PHP config
COPY config/php.ini /usr/local/etc/php/

# NOT USED ANYMORE - GIT CLONE INSTEAD
# Copy in emoncms files, files can be mounted from local FS for dev see docker-compose
# ADD ./emoncms /var/www/html

# Clone in master Emoncms repo & modules - overwritten in development with local FS files
RUN git clone https://github.com/emoncms/emoncms.git /var/www/html
RUN git clone https://github.com/emoncms/dashboard.git /var/www/html/Modules/dashboard
RUN git clone https://github.com/emoncms/graph.git /var/www/html/Modules/graph


COPY docker.settings.php /var/www/html/settings.php

# Create folders & set permissions for feed-engine data folders (mounted as docker volumes in docker-compose)
RUN mkdir /var/lib/phpfiwa
RUN mkdir /var/lib/phpfina
RUN mkdir /var/lib/phptimeseries
RUN chown www-data:root /var/lib/phpfiwa
RUN chown www-data:root /var/lib/phpfina
RUN chown www-data:root /var/lib/phptimeseries

# Create Emoncms logfile
RUN touch /var/log/emoncms.log
RUN chmod 666 /var/log/emoncms.log


# TODO
# Add Pecl :
# - dio
# - Swiftmailer
# - redis
# - mqtt
