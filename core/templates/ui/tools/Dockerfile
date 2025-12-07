FROM php:8.2-fpm-alpine

# Install Nginx and dependencies
RUN apk add --no-cache nginx git postgresql-dev libzip-dev unzip

# Install PHP Extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql pdo_pgsql pgsql opcache

# Install Redis & Memcached extensions
RUN apk add --no-cache autoconf build-base libmemcached-dev zlib-dev openssl-dev \
    && pecl install redis memcached mongodb \
    && docker-php-ext-enable redis memcached mongodb \
    && apk del autoconf build-base

# Configure Nginx
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /run/nginx

# Configure PHP (Suppress all warnings for legacy tools)
RUN echo "error_reporting = E_ERROR | E_PARSE" > /usr/local/etc/php/conf.d/error_reporting.ini && \
    echo "display_errors = Off" >> /usr/local/etc/php/conf.d/error_reporting.ini && \
    echo "log_errors = On" >> /usr/local/etc/php/conf.d/error_reporting.ini

# Setup Web Root
WORKDIR /var/www/html

# --- 1. Adminer ---
RUN mkdir -p adminer && \
    curl -L -o adminer/index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

# --- 2. PhpMyAdmin ---
RUN curl -L https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip -o pma.zip && \
    unzip pma.zip && \
    mv phpMyAdmin-5.2.1-all-languages phpmyadmin && \
    rm pma.zip && \
    cp phpmyadmin/config.sample.inc.php phpmyadmin/config.inc.php && \
    sed -i "s/\$cfg\['blowfish_secret'\] = '';/\$cfg\['blowfish_secret'\] = 'stackored-secret-key-12345678901234567890';/" phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][\$i]['host'] = 'stackored-mysql';" >> phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][\$i]['port'] = '3306';" >> phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][\$i]['auth_type'] = 'cookie';" >> phpmyadmin/config.inc.php && \
    echo "\$cfg['AllowArbitraryServer'] = true;" >> phpmyadmin/config.inc.php

# --- 3. PhpMemcachedAdmin ---
RUN mkdir -p phpmemcachedadmin && \
    curl -L https://github.com/elijaa/phpmemcachedadmin/archive/refs/heads/master.zip -o pma_mem.zip && \
    unzip pma_mem.zip && \
    mv phpmemcachedadmin-master/* phpmemcachedadmin/ && \
    rm -rf phpmemcachedadmin-master pma_mem.zip

# --- 5. OpCacheGUI ---
RUN mkdir -p opcache && \
    curl -L https://raw.githubusercontent.com/amnuts/opcache-gui/master/index.php -o opcache/index.php

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# --- 6. MongoDB-PHP-GUI ---
RUN git clone https://github.com/SamuelTallet/MongoDB-PHP-GUI.git phpmongo && \
    cd phpmongo && \
    composer install --no-dev --optimize-autoloader && \
    echo "<?php" > config.php && \
    echo "define('MONGO_HOST', 'stackored-mongo');" >> config.php && \
    echo "define('MONGO_PORT', 27017);" >> config.php && \
    echo "define('MONGO_USER', 'root');" >> config.php && \
    echo "define('MONGO_PASS', 'root');" >> config.php && \
    echo "define('MONGO_AUTH_DB', 'admin');" >> config.php

# --- 7. PhpPgAdmin ---
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
