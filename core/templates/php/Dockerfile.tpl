###################################################################
# STACKORED PHP DOCKERFILE TEMPLATE
###################################################################

FROM php:{{ PHP_VERSION }}-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
git zip unzip curl libpng-dev libonig-dev libxml2-dev libzip-dev libpq-dev \
&& docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring xml zip opcache \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Custom extensions (dynamic)
COPY php-extensions.sh /usr/local/bin/php-extensions.sh
RUN chmod +x /usr/local/bin/php-extensions.sh

# Copy configs
COPY php.ini /usr/local/etc/php/php.ini
COPY php-cli.ini /usr/local/etc/php/php-cli.ini
COPY php-fpm.conf /usr/local/etc/php-fpm.conf

# Copy pools
COPY fpm-pool.d/ /usr/local/etc/php-fpm.d/

WORKDIR /var/www/html
