###################################################################
# STACKORED PHP GLOBAL CONFIG TEMPLATE
###################################################################

[PHP]
engine = On
short_open_tag = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = -1

expose_php = Off
max_execution_time = 120
max_input_time = 120
memory_limit = 512M

error_reporting = E_ALL
display_errors = Off
log_errors = On
error_log = /var/log/php/php-error.log

post_max_size = 128M
upload_max_filesize = 128M

default_charset = "UTF-8"

date.timezone = "{{ HOST_TIMEZONE }}"

[CLI Server]
cli_server.color = On

[opcache]
opcache.enable = 1
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 20000
opcache.validate_timestamps = 1
opcache.revalidate_freq = 1
