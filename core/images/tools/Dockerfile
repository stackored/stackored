FROM php:8.2-fpm-alpine

# Install Nginx and dependencies
RUN apk add --no-cache nginx git postgresql-dev libzip-dev unzip

# Install PHP Extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql pdo_pgsql opcache

# Install Redis & Memcached extensions
RUN apk add --no-cache autoconf build-base libmemcached-dev zlib-dev \
    && pecl install redis memcached \
    && docker-php-ext-enable redis memcached \
    && apk del autoconf build-base

# Configure Nginx
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /run/nginx

# Setup Web Root
WORKDIR /var/www/html

# --- 1. Adminer ---
# Adminer is a single file
RUN mkdir -p adminer && \
    curl -L -o adminer/index.php https://github.com/vrana/adminer/releases/download/v4.16.1/adminer-4.16.1.php

# --- 2. PhpMyAdmin ---
RUN curl -L https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip -o pma.zip && \
    unzip pma.zip && \
    mv phpMyAdmin-5.2.1-all-languages phpmyadmin && \
    rm pma.zip && \
    cp phpmyadmin/config.sample.inc.php phpmyadmin/config.inc.php && \
    # Allow arbitrary server connection
    sed -i "s/\$cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost';/\$cfg\['Servers'\]\[\$i\]\['host'\] = 'stackored-mysql';/" phpmyadmin/config.inc.php && \
    echo "\$cfg['AllowArbitraryServer'] = true;" >> phpmyadmin/config.inc.php

# --- 3. PhpRedmin ---
# Using a fork or source that supports PHP 8+ if needed, or standard repo
RUN git clone https://github.com/sasanrose/phpredmin.git phpredmin && \
    cd phpredmin && composer install --no-dev || true
# Note: PhpRedmin might need Composer. Installing composer first.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# --- 4. PhpMemcachedAdmin ---
RUN mkdir -p phpmemcachedadmin && \
    curl -L https://github.com/elijaa/phpmemcachedadmin/archive/refs/heads/master.zip -o pma_mem.zip && \
    unzip pma_mem.zip && \
    mv phpmemcachedadmin-master/* phpmemcachedadmin/ && \
    rm -rf phpmemcachedadmin-master pma_mem.zip

# --- 5. OpCacheGUI ---
RUN mkdir -p opcache && \
    curl -L https://raw.githubusercontent.com/amnuts/opcache-gui/master/index.php -o opcache/index.php

# --- 6. PhpPgAdmin ---
# GitHub latest zip
RUN curl -L https://github.com/phppgadmin/phppgadmin/releases/download/REL_7-13-0/phpPgAdmin-7.13.0.zip -o ppa.zip && \
    unzip ppa.zip && \
    mv phpPgAdmin-7.13.0 phppgadmin && \
    rm ppa.zip && \
    cp phppgadmin/conf/config.inc.php-dist phppgadmin/conf/config.inc.php && \
    sed -i "s/\$conf\['servers'\]\[0\]\['host'\] = '';/\$conf\['servers'\]\[0\]\['host'\] = 'stackored-postgres';/" phppgadmin/conf/config.inc.php

# Permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

# Start Nginx and PHP-FPM
CMD sh -c "php-fpm -D && nginx -g 'daemon off;'"
