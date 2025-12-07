; ######################################################################
; STACKORED SUPERVISOR CONFIG TEMPLATE
; Manages multiple command workers inside the same container.
; ######################################################################

[supervisord]
nodaemon=true
logfile=/var/log/supervisord.log
pidfile=/var/run/supervisord.pid
user=root

; -----------------------------------------
; PHP-FPM
; -----------------------------------------
[program:php-fpm]
command=/usr/sbin/php-fpm8 -F
autostart=true
autorestart=true
priority=10
stdout_logfile=/var/log/php-fpm-supervisor.log
stderr_logfile=/var/log/php-fpm-supervisor-error.log

; -----------------------------------------
; Laravel Queue Worker (Optional)
; -----------------------------------------
{% if ENABLE_QUEUE == "true" %}
[program:queue-worker]
command=php /app/artisan queue:work --tries=3 --timeout=90
directory=/app
autostart=true
autorestart=true
priority=20
stdout_logfile=/var/log/queue-worker.log
stderr_logfile=/var/log/queue-worker-error.log
{% endif %}

; -----------------------------------------
; Schedule Worker (Optional)
; -----------------------------------------
{% if ENABLE_SCHEDULER == "true" %}
[program:scheduler]
command=php /app/artisan schedule:work
directory=/app
autostart=true
autorestart=true
priority=30
stdout_logfile=/var/log/scheduler.log
stderr_logfile=/var/log/scheduler-error.log
{% endif %}
