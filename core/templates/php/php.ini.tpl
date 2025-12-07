###################################################################
# STACKORED php.ini TEMPLATE (FPM Version)
###################################################################

[PHP]
display_errors = Off
display_startup_errors = Off
log_errors = On
error_log = /var/log/php/php-fpm-error.log

memory_limit = 512M
max_execution_time = 180
max_input_time = 180
max_input_vars = 5000

upload_max_filesize = 128M
post_max_size = 128M

date.timezone = "{{ HOST_TIMEZONE }}"

session.save_handler = files
session.gc_maxlifetime = 1440

[opcache]
opcache.enable = 1
opcache.enable_cli = 0
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
opcache.revalidate_freq = 2
