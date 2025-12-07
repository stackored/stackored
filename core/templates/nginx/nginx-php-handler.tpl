###################################################################
# STACKORED NGINX PHP HANDLER TEMPLATE
###################################################################

location ~ \.php$ {
try_files $uri =404;

fastcgi_pass php-upstream-{{ PROJECT_SLUG }};
fastcgi_index index.php;

fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
include fastcgi_params;

# Timeouts
fastcgi_connect_timeout 60s;
fastcgi_send_timeout 180s;
fastcgi_read_timeout 180s;

# Buffers
fastcgi_buffer_size 128k;
fastcgi_buffers 4 256k;
fastcgi_busy_buffers_size 512k;
}
