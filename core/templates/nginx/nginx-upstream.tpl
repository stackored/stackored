###################################################################
# STACKORED NGINX UPSTREAM TEMPLATE
###################################################################

upstream php-upstream-{{ PROJECT_SLUG }} {
server {{ PROJECT_SLUG }}-php:9000 max_fails=3 fail_timeout=30s;
keepalive 8;
}
