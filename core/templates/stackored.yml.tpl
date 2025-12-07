###################################################################
# STACKORED CONFIG TEMPLATE
# This file becomes stackored.yml after generation.
###################################################################

version: "1.0"

stackored:
name: "{{ STACKORED_NAME | default('Stackored Development Environment') }}"
description: "{{ STACKORED_DESCRIPTION | default('Multi-project modular PHP development stack') }}"
network: "{{ DOCKER_DEFAULT_NETWORK }}"

defaults:
php: "{{ DEFAULT_PHP_VERSION }}"
webserver: "{{ DEFAULT_WEBSERVER }}"
document_root: "{{ DEFAULT_DOCUMENT_ROOT }}"

paths:
projects: "projects"
templates: "stackored/core/templates"
core: "stackored/core"
runtime: "stackored/runtime"
generated: "stackored/generated"

features:
allow_override: true
strict_mode: "{{ STACKORED_STRICT }}"
verbose: "{{ STACKORED_VERBOSE }}"
dry_run: "{{ STACKORED_DRY_RUN }}"

modules:
mysql: "{{ ENABLE_MYSQL }}"
redis: "{{ ENABLE_REDIS }}"
rabbitmq: "{{ ENABLE_RABBITMQ }}"
elasticsearch: "{{ ENABLE_ELASTICSEARCH }}"
memcached: "{{ ENABLE_MEMCACHED }}"
postgres: "{{ ENABLE_POSTGRES }}"
mongo: "{{ ENABLE_MONGO }}"
mailhog: "{{ ENABLE_MAILHOG }}"
sonarqube: "{{ ENABLE_SONARQUBE }}"
meilisearch: "{{ ENABLE_MEILISEARCH }}"

versions:
php: "{{ DEFAULT_PHP_VERSION }}"
mysql: "{{ MYSQL_VERSION }}"
mariadb: "{{ MARIADB_VERSION }}"
redis: "{{ REDIS_VERSION }}"
memcached: "{{ MEMCACHED_VERSION }}"
postgres: "{{ POSTGRES_VERSION }}"
mongo: "{{ MONGO_VERSION }}"
rabbitmq: "{{ RABBITMQ_VERSION }}"
elasticsearch: "{{ ELASTICSEARCH_VERSION }}"
