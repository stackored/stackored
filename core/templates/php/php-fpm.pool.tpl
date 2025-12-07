###################################################################
# STACKORED PHP-FPM POOL TEMPLATE
###################################################################

[{{ PROJECT_SLUG }}]
user = www-data
group = www-data

listen = /var/run/php-{{ PROJECT_SLUG }}.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

pm = dynamic
pm.max_children = 20
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
pm.max_requests = 500

decorate_workers_output = no

php_admin_value[error_log] = /var/log/php/{{ PROJECT_SLUG }}-error.log
php_admin_flag[log_errors] = on

php_value[session.save_path] = /var/lib/php/sessions/{{ PROJECT_SLUG }}
