###################################################################
# STACKORED php.cli.ini TEMPLATE
###################################################################

[PHP]
display_errors = On
display_startup_errors = On

memory_limit = -1
max_execution_time = 0
max_input_time = -1

date.timezone = "{{ HOST_TIMEZONE }}"

[opcache]
; CLI opcache disabled for development
opcache.enable_cli = 0
