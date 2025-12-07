#!/usr/bin/env bash
# ###################################################################
# STACKORED HEALTHCHECK TEMPLATE
# Checks service availability for webserver, php-fpm, databases, etc.
# ###################################################################

set -e

SERVICE="{{ SERVICE_NAME }}"
TIMEOUT="${HEALTHCHECK_TIMEOUT:-5}"

log() {
echo "[healthcheck][$SERVICE] $1"
}

case "$SERVICE" in

php-fpm)
if curl -s --max-time $TIMEOUT http://localhost:{{ HEALTHCHECK_PORT }} >/dev/null; then
log "PHP-FPM OK"
exit 0
else
log "PHP-FPM FAIL"
exit 1
fi
;;

nginx|httpd)
if curl -s --max-time $TIMEOUT http://localhost >/dev/null; then
log "Webserver OK"
exit 0
else
log "Webserver FAIL"
exit 1
fi
;;

mysql)
if mysqladmin ping -h localhost --silent; then
log "MySQL OK"
exit 0
else
log "MySQL FAIL"
exit 1
fi
;;

postgres)
if pg_isready -q; then
log "Postgres OK"
exit 0
else
log "Postgres FAIL"
exit 1
fi
;;

redis)
if redis-cli ping | grep -q PONG; then
log "Redis OK"
exit 0
else
log "Redis FAIL"
exit 1
fi
;;

*)
log "Unknown service type: $SERVICE"
exit 0
;;
esac
