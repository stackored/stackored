#!/bin/bash
###################################################################
# STACKORED TRAEFIK GENERATOR MODULE
# Traefik konfigürasyonu üretme
###################################################################

generate_traefik_routes() {
    log_info "Generating traefik routes..."
    
    mkdir -p "$ROOT_DIR/core/traefik/dynamic"
    local output="$ROOT_DIR/core/traefik/dynamic/routes.yml"
    mkdir -p "$ROOT_DIR/core/traefik"
    
    # Start with routers section
    cat > "$output" <<EOF
http:
  routers:
    traefik:
      rule: "Host(\`traefik.${DEFAULT_TLD_SUFFIX}\`)"
      entryPoints:
        - websecure
      service: api@internal
      tls: {}
EOF
    
    # Add all routers
    add_router_if_enabled "RABBITMQ_ENABLE" "rabbitmq" "RABBITMQ_URL" >> "$output"
    add_router_if_enabled "MAILHOG_ENABLE" "mailhog" "MAILHOG_URL" >> "$output"
    add_router_if_enabled "KIBANA_ENABLE" "kibana" "KIBANA_URL" >> "$output"
    add_router_if_enabled "GRAFANA_ENABLE" "grafana" "GRAFANA_URL" >> "$output"
    add_router_if_enabled "SONARQUBE_ENABLE" "sonarqube" "SONARQUBE_URL" >> "$output"
    add_router_if_enabled "SENTRY_ENABLE" "sentry" "SENTRY_URL" >> "$output"
    add_router_if_enabled "MEILISEARCH_ENABLE" "meilisearch" "MEILISEARCH_URL" >> "$output"
    add_router_if_enabled "TOMCAT_ENABLE" "tomcat" "TOMCAT_URL" >> "$output"
    add_router_if_enabled "KONG_ENABLE" "kong-gateway" "KONG_URL" >> "$output"
    add_router_if_enabled "KONG_ENABLE" "kong-admin" "KONG_ADMIN_URL" >> "$output"
    add_router_if_enabled "NETDATA_ENABLE" "netdata" "NETDATA_URL" >> "$output"
    add_router_if_enabled "KAFBAT_ENABLE" "kafbat" "KAFBAT_URL" >> "$output"
    add_router_if_enabled "ACTIVEMQ_ENABLE" "activemq" "ACTIVEMQ_URL" >> "$output"
    
    # Tools container admin tools (subdomain-based routing - no path rewriting needed)
    if [ "${TOOLS_CONTAINER_ENABLE}" = "true" ]; then
        add_router_if_enabled "TOOLS_CONTAINER_ENABLE" "phpmyadmin" "PHPMYADMIN_URL" >> "$output"
        add_router_if_enabled "TOOLS_CONTAINER_ENABLE" "adminer" "ADMINER_URL" >> "$output"
        add_router_if_enabled "TOOLS_CONTAINER_ENABLE" "phppgadmin" "PHPPGADMIN_URL" >> "$output"
        add_router_if_enabled "TOOLS_CONTAINER_ENABLE" "phpmemcachedadmin" "PHPMEMCACHEDADMIN_URL" >> "$output"
        add_router_if_enabled "TOOLS_CONTAINER_ENABLE" "phpmongo" "PHPMONGO_URL" >> "$output"
        add_router_if_enabled "TOOLS_CONTAINER_ENABLE" "opcache" "OPCACHE_URL" >> "$output"
    fi
    
    # Add services section
    cat >> "$output" <<EOF

  services:
EOF
    
    # Add all services
    add_service_if_enabled "RABBITMQ_ENABLE" "rabbitmq" "15672" >> "$output"
    add_service_if_enabled "MAILHOG_ENABLE" "mailhog" "8025" >> "$output"
    add_service_if_enabled "KIBANA_ENABLE" "kibana" "5601" >> "$output"
    add_service_if_enabled "GRAFANA_ENABLE" "grafana" "3000" >> "$output"
    add_service_if_enabled "SONARQUBE_ENABLE" "sonarqube" "9000" >> "$output"
    add_service_if_enabled "SENTRY_ENABLE" "sentry" "9000" >> "$output"
    add_service_if_enabled "MEILISEARCH_ENABLE" "meilisearch" "7700" >> "$output"
    add_service_if_enabled "TOMCAT_ENABLE" "tomcat" "8080" >> "$output"
    # Kong services - both point to same container but different ports
    if [ "${KONG_ENABLE}" = "true" ]; then
        cat >> "$output" <<EOF
    kong-gateway:
      loadBalancer:
        servers:
          - url: "http://stackored-kong:8000"
    kong-admin:
      loadBalancer:
        servers:
          - url: "http://stackored-kong:8001"
EOF
    fi
    add_service_if_enabled "NETDATA_ENABLE" "netdata" "19999" >> "$output"
    add_service_if_enabled "KAFBAT_ENABLE" "kafbat" "8080" >> "$output"
    add_service_if_enabled "ACTIVEMQ_ENABLE" "activemq" "8161" >> "$output"
    
    # Tools container services (subdomain-based, no path rewriting)
    if [ "${TOOLS_CONTAINER_ENABLE}" = "true" ]; then
        for tool in phpmyadmin adminer phppgadmin phpmemcachedadmin phpmongo opcache; do
            cat >> "$output" <<EOF
    ${tool}:
      loadBalancer:
        servers:
          - url: "http://stackored-tools:80"
EOF
        done
    fi
    
    # Add TLS configuration - Force use of core/certs certificates
    if [ "${SSL_ENABLE:-false}" = "true" ]; then
        cat >> "$output" <<EOF

# TLS Configuration - Force use of core/certs certificates
tls:
  stores:
    default:
      defaultCertificate:
        certFile: /certs/stackored-wildcard.crt
        keyFile: /certs/stackored-wildcard.key
  certificates:
    - certFile: /certs/stackored-wildcard.crt
      keyFile: /certs/stackored-wildcard.key
  options:
    default:
      minVersion: VersionTLS12
      sniStrict: false
EOF
    fi
    
    log_success "Generated traefik routes"
}

# Add Traefik router if service enabled
add_router_if_enabled() {
    local enable_var=$1
    local service=$2
    local url_var=$3
    
    eval "local enabled=\${${enable_var}:-false}"
    eval "local url=\${${url_var}:-$service}"
    
    if [ "$enabled" = "true" ]; then
        cat <<EOF
    ${service}:
      rule: "Host(\`${url}.${DEFAULT_TLD_SUFFIX}\`)"
      entryPoints:
        - websecure
      service: ${service}
      tls: {}
EOF
    fi
}



# Add Traefik service if enabled
add_service_if_enabled() {
    local enable_var=$1
    local service=$2
    local port=$3
    
    eval "local enabled=\${${enable_var}:-false}"
    
    if [ "$enabled" = "true" ]; then
        cat <<EOF
    ${service}:
      loadBalancer:
        servers:
          - url: "http://stackored-${service}:${port}"
EOF
    fi
}

# Generate Traefik config
generate_traefik_config() {
    log_info "Generating traefik config..."
    
    local ssl_enabled="${SSL_ENABLE:-false}"
    local redirect_https="${REDIRECT_TO_HTTPS:-false}"
    local output="$ROOT_DIR/core/traefik/traefik.yml"
    
    mkdir -p "$ROOT_DIR/core/traefik"
    
    cat > "$output" <<EOF
api:
  dashboard: true
  insecure: false

providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: ${DOCKER_DEFAULT_NETWORK:-stackored-net}
  file:
    directory: "/etc/traefik/dynamic"
    watch: true

entryPoints:
  web:
    address: ":80"
EOF
    
    if [ "$ssl_enabled" = "true" ]; then
        if [ "$redirect_https" = "true" ]; then
            cat >> "$output" <<EOF
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
EOF
        fi
        
        cat >> "$output" <<EOF
  websecure:
    address: ":443"
EOF
    fi
    
    log_success "Generated traefik config"
}
