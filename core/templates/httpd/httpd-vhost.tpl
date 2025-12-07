###################################################################
# STACKORED APACHE VHOST TEMPLATE
###################################################################

<VirtualHost *:9000>
    ServerName {{ PROJECT_DOMAIN }}
    ServerAlias www.{{ PROJECT_DOMAIN }}

    DocumentRoot /var/www/html/{{ PROJECT_DOCROOT }}

    <Directory "/var/www/html/{{ PROJECT_DOCROOT }}">
    Options FollowSymLinks
    AllowOverride All
    Require all granted
    </Directory>

    ErrorLog "/var/log/apache2/{{ PROJECT_SLUG }}-error.log"
    CustomLog "/var/log/apache2/{{ PROJECT_SLUG }}-access.log" combined

    # Rewrite handling
    <IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^ /index.php [L]
    </IfModule>

    # Proxy to PHP-FPM
    <FilesMatch "\.php$">
    SetHandler "proxy:fcgi://{{ PROJECT_SLUG }}-php:9000"
    </FilesMatch>

    # Security Headers
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
</VirtualHost>
