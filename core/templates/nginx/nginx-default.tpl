###################################################################
# STACKORED NGINX DEFAULT CONFIG TEMPLATE
###################################################################

user  nginx;
worker_processes auto;

events {
worker_connections 2048;
}

http {
include       /etc/nginx/mime.types;
default_type  application/octet-stream;

sendfile           on;
tcp_nopush         on;
tcp_nodelay        on;
keepalive_timeout  65;
types_hash_max_size 4096;

server_tokens off;

client_max_body_size 128M;

# Gzip Compression
gzip on;
gzip_disable "msie6";
gzip_vary on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

# Include upstream + vhost definitions
include /etc/nginx/conf.d/upstream-*.conf;
include /etc/nginx/conf.d/vhost-*.conf;
}
