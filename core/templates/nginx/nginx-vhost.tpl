###################################################################
# STACKORED NGINX VHOST TEMPLATE
###################################################################

server {
listen 9000;
server_name {{ PROJECT_DOMAIN }};

root /var/www/html/{{ PROJECT_DOCROOT }};
index index.php index.html index.htm;

access_log /var/log/nginx/{{ PROJECT_SLUG }}.access.log;
error_log  /var/log/nginx/{{ PROJECT_SLUG }}.error.log;

# Security
server_tokens off;

# Static file handling
location / {
try_files $uri $uri/ /index.php?$query_string;
}

# PHP Handler
include /etc/nginx/conf.d/php-handler-{{ PROJECT_SLUG }}.conf;

# Deny sensitive directories
location ~ /\.(git|svn|env|htaccess) {
deny all;
}
}
