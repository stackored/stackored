#!/bin/bash
###################################################################
# STACKORED CONSTANTS
# Tüm sabit değerler (magic numbers, strings) burada tanımlanır
# CONST_ prefix'i ile .env değişkenlerinden ayrılır
###################################################################

# Varsayılan Değerler (Fallback)
readonly CONST_DEFAULT_PHP_VERSION="8.2"
readonly CONST_DEFAULT_WEBSERVER="nginx"
readonly CONST_DEFAULT_WEBSERVER_ALT="apache"

# Port Numaraları
readonly CONST_PORT_HTTP=80
readonly CONST_PORT_HTTPS=443
readonly CONST_PORT_TRAEFIK_DASHBOARD=8080

# Servis Portları
readonly CONST_PORT_MAILHOG=8025
readonly CONST_PORT_RABBITMQ_MGMT=15672
readonly CONST_PORT_KIBANA=5601
readonly CONST_PORT_GRAFANA=3000
readonly CONST_PORT_SONARQUBE=9000
readonly CONST_PORT_SENTRY=9000
readonly CONST_PORT_MEILISEARCH=7700
readonly CONST_PORT_TOMCAT=8080
readonly CONST_PORT_KONG_GATEWAY=8000
readonly CONST_PORT_KONG_ADMIN=8001
readonly CONST_PORT_NETDATA=19999
readonly CONST_PORT_KAFBAT=8080
readonly CONST_PORT_ACTIVEMQ=8161

# Dosya Yolları (Relative to ROOT_DIR)
readonly CONST_PATH_TEMPLATES="core/templates"
readonly CONST_PATH_GENERATED_CONFIGS="core/generated-configs"
readonly CONST_PATH_TRAEFIK_CONFIG="core/traefik"
readonly CONST_PATH_TRAEFIK_DYNAMIC="core/traefik/dynamic"
readonly CONST_PATH_CERTS="core/certs"
readonly CONST_PATH_PROJECTS="projects"

# Dosya Adları
readonly CONST_FILE_STACKORED_JSON="stackored.json"
readonly CONST_FILE_STACKORED_YML="stackored.yml"
readonly CONST_FILE_DYNAMIC_YML="docker-compose.dynamic.yml"
readonly CONST_FILE_PROJECTS_YML="docker-compose.projects.yml"
readonly CONST_FILE_TRAEFIK_CONFIG="traefik.yml"
readonly CONST_FILE_TRAEFIK_ROUTES="routes.yml"

# Config Dosya Adları
readonly CONST_CONFIG_NGINX="nginx.conf"
readonly CONST_CONFIG_APACHE="apache.conf"
readonly CONST_CONFIG_PHP_INI="php.ini"
readonly CONST_CONFIG_PHP_FPM="php-fpm.conf"

# Docker Image Adları
readonly CONST_IMAGE_TRAEFIK="traefik:latest"
readonly CONST_IMAGE_NGINX="nginx:alpine"

# Container Prefix
readonly CONST_CONTAINER_PREFIX="stackored-"

# Network
readonly CONST_DEFAULT_NETWORK="stackored-net"

# TLS
readonly CONST_TLS_MIN_VERSION="VersionTLS12"

# Stackored Config Dizini
readonly CONST_STACKORED_CONFIG_DIR=".stackored"
