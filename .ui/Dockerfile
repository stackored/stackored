FROM php:8.2-fpm-alpine

# Install nginx and Docker CLI
RUN apk add --no-cache nginx docker-cli docker-cli-compose

# Create necessary directories and set permissions
RUN mkdir -p /var/run/php-fpm /var/log/nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/run/php-fpm

# Copy nginx configuration
COPY nginx.conf /etc/nginx/http.d/default.conf

# Configure PHP-FPM to use nginx user (keep default TCP port)
RUN sed -i 's/^user = www-data/user = nginx/g' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/^group = www-data/group = nginx/g' /usr/local/etc/php-fpm.d/www.conf

# Create startup script with docker socket permissions
RUN echo '#!/bin/sh' > /start.sh && \
    echo '# Fix docker socket permissions' >> /start.sh && \
    echo 'if [ -S /var/run/docker.sock ]; then' >> /start.sh && \
    echo '  chmod 666 /var/run/docker.sock' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo 'php-fpm -D' >> /start.sh && \
    echo 'nginx -g "daemon off;"' >> /start.sh && \
    chmod +x /start.sh

WORKDIR /usr/share/nginx/html

EXPOSE 80

CMD ["/start.sh"]
