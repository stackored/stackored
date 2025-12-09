#!/bin/bash
set -eo pipefail

# Stackored Generator - Pure Bash Implementation
# Compatible with Bash 3.x+ (macOS default)
# No PHP dependency required!

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[OK]${NC} $1" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Load .env
load_env() {
    log_info "Loading environment..."
    [ ! -f "$ROOT_DIR/.env" ] && { log_error ".env not found"; exit 1; }
    set -a
    source "$ROOT_DIR/.env"
    set +a
}

# Process template - convert to envsubst syntax and process
process_template() {
    local template_file=$1
    [ ! -f "$template_file" ] && return 1
    
    # Convert {{ VAR }} to ${VAR} and {{ VAR | default('x') }} to ${VAR:-x}
    # Use [[:space:]]* for BSD sed compatibility (macOS)
    # Then use envsubst for actual replacement
    sed -e 's/{{[[:space:]]*\([A-Z0-9_]*\)[[:space:]]*}}/${\1}/g' \
        -e "s/{{[[:space:]]*\([A-Z0-9_]*\)[[:space:]]*|[[:space:]]*default('\([^']*\)')[[:space:]]*}}/\${\1:-\2}/g" \
        -e "s/{{[[:space:]]*\([A-Z0-9_]*\)[[:space:]]*|[[:space:]]*default(\"\([^\"]*\)\")[[:space:]]*}}/\${\1:-\2}/g" \
        "$template_file" | envsubst
}

# Include module if enabled
include_module() {
    local enable_var=$1
    local template_path=$2
    local full_path="$ROOT_DIR/core/templates/$template_path"
    
    # Check if enabled
    eval "local enabled=\${${enable_var}:-false}"
    
    if [ "$enabled" = "true" ] && [ -f "$full_path" ]; then
        log_info "Including: $enable_var"
        
        # Process template and extract only service definitions
        # Skip: comments (#), "services:" line, "volumes:" section
        # Fix: indentation for ports/networks and their list items
        process_template "$full_path" | \
            awk '
                /^#/ { next }                      # Skip ALL comment lines
                /^services:/ { next }              # Skip services header  
                /^volumes:/ { in_volumes=1 }       # Mark volumes section
                in_volumes { next }                # Skip volumes section
                /^[[:space:]]*$/ && !started { next }  # Skip leading blank lines
                
                # Track ports/networks sections
                /^ports:/ { 
                    print "    ports:"
                    in_ports=1
                    next
                }
                /^networks:/ { 
                    print "    networks:"
                    in_networks=1
                    next
                }
                
                # Reset section tracking when we hit a new top-level key
                /^[a-z_]+:/ && !/^  / { 
                    in_ports=0
                    in_networks=0
                }
                
                # Indent list items in ports/networks sections
                in_ports && /^- / { 
                    sub(/^- /, "      - ")
                    print
                    next
                }
                in_networks && /^- / { 
                    sub(/^- /, "      - ")
                    print
                    next
                }
                
                { started=1; print }               # Print everything else
            '
        
        echo ""
    fi
}

# Generate base stackored.yml
generate_base_compose() {
    log_info "Generating stackored.yml (base compose)..."
    
    local output="$ROOT_DIR/stackored.yml"
    local template="$ROOT_DIR/core/compose/base.yml"
    
    if [ -f "$template" ]; then
        process_template "$template" > "$output"
    else
        # Fallback: create minimal base compose
        cat > "$output" <<'EOF'
services:
  traefik:
    image: traefik:latest
    container_name: stackored-traefik
    restart: unless-stopped
    command:
      - "--api.dashboard=true"
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedByDefault=false"
      - "--providers.file.directory=/etc/traefik/dynamic"
      - "--providers.file.watch=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./core/traefik/traefik.yml:/etc/traefik/traefik.yml:ro"
      - "./core/traefik/dynamic:/etc/traefik/dynamic:ro"
      - "./core/certs:/certs:ro"
    networks:
      - stackored-net

networks:
  stackored-net:
    name: stackored-net
    driver: bridge
EOF
    fi
    
    log_success "Generated stackored.yml"
}

# Generate docker-compose.dynamic.yml
generate_dynamic_compose() {
    log_info "Generating docker-compose.dynamic.yml..."
    
    local output="$ROOT_DIR/docker-compose.dynamic.yml"
    echo "services:" > "$output"
    echo "" >> "$output"
    
    # Databases
    include_module "MYSQL_ENABLE" "database/mysql/docker-compose.mysql.tpl" >> "$output"
    include_module "MARIADB_ENABLE" "database/mariadb/docker-compose.mariadb.tpl" >> "$output"
    include_module "POSTGRES_ENABLE" "database/postgres/docker-compose.postgres.tpl" >> "$output"
    include_module "MONGO_ENABLE" "database/mongo/docker-compose.mongo.tpl" >> "$output"
    include_module "CASSANDRA_ENABLE" "database/cassandra/docker-compose.cassandra.tpl" >> "$output"
    include_module "PERCONA_ENABLE" "database/percona/docker-compose.percona.tpl" >> "$output"
    include_module "COUCHDB_ENABLE" "database/couchdb/docker-compose.couchdb.tpl" >> "$output"
    include_module "COUCHBASE_ENABLE" "database/couchbase/docker-compose.couchbase.tpl" >> "$output"
    
    # Caching
    include_module "REDIS_ENABLE" "cache/redis/docker-compose.redis.tpl" >> "$output"
    include_module "MEMCACHED_ENABLE" "cache/memcached/docker-compose.memcached.tpl" >> "$output"
    
    # Message Queues
    include_module "RABBITMQ_ENABLE" "messaging/rabbitmq/docker-compose.rabbitmq.tpl" >> "$output"
    include_module "NATS_ENABLE" "messaging/nats/docker-compose.nats.tpl" >> "$output"
    include_module "KAFKA_ENABLE" "messaging/kafka/docker-compose.kafka.tpl" >> "$output"
    include_module "KAFBAT_ENABLE" "messaging/kafbat/docker-compose.kafbat.tpl" >> "$output"
    include_module "ACTIVEMQ_ENABLE" "messaging/activemq/docker-compose.activemq.tpl" >> "$output"
    
    # Search
    include_module "ELASTICSEARCH_ENABLE" "search/elasticsearch/docker-compose.elasticsearch.tpl" >> "$output"
    include_module "MEILISEARCH_ENABLE" "search/meilisearch/docker-compose.meilisearch.tpl" >> "$output"
    include_module "SOLR_ENABLE" "search/solr/docker-compose.solr.tpl" >> "$output"
    
    # Monitoring
    include_module "KIBANA_ENABLE" "monitoring/kibana/docker-compose.kibana.tpl" >> "$output"
    include_module "GRAFANA_ENABLE" "monitoring/grafana/docker-compose.grafana.tpl" >> "$output"
    include_module "LOGSTASH_ENABLE" "monitoring/logstash/docker-compose.logstash.tpl" >> "$output"
    include_module "NETDATA_ENABLE" "utils/netdata/docker-compose.netdata.tpl" >> "$output"
    
    # QA
    include_module "SONARQUBE_ENABLE" "qa/sonarqube/docker-compose.sonarqube.tpl" >> "$output"
    include_module "SENTRY_ENABLE" "qa/sentry/docker-compose.sentry.tpl" >> "$output"
    include_module "BLACKFIRE_ENABLE" "qa/blackfire/docker-compose.blackfire.tpl" >> "$output"
    
    # App Servers
    include_module "TOMCAT_ENABLE" "appserver/tomcat/docker-compose.tomcat.tpl" >> "$output"
    include_module "KONG_ENABLE" "appserver/kong/docker-compose.kong.tpl" >> "$output"
    
    # Tools
    include_module "MAILHOG_ENABLE" "utils/mailhog/docker-compose.mailhog.tpl" >> "$output"
    include_module "COMPOSER_ENABLE" "tools/composer/docker-compose.composer.tpl" >> "$output"
    include_module "NGROK_ENABLE" "utils/ngrok/docker-compose.ngrok.tpl" >> "$output"
    include_module "SELENIUM_ENABLE" "utils/selenium/docker-compose.selenium.tpl" >> "$output"
    include_module "TOOLS_CONTAINER_ENABLE" "ui/tools/docker-compose.tools.tpl" >> "$output"
    
    # Add volumes section
    echo "" >> "$output"
    echo "volumes:" >> "$output"
    
    # Extract volume names to temp file
    local volumes_tmp="$ROOT_DIR/.volumes.tmp"
    > "$volumes_tmp"  # Clear temp file
    
    # Use find instead of glob for Bash 3.x compatibility
    find "$ROOT_DIR/core/templates" -name "*.tpl" -type f | while read -r tpl; do
        # Extract volume names
        awk '/^volumes:/,0 {
            if (/^  [a-z]/) {
                gsub(/:.*/, "")
                gsub(/^  /, "")
                if (length($0) > 0) print "  " $0 ": {}"
            }
        }' "$tpl" >> "$volumes_tmp" 2>/dev/null || true
    done
    
    # Sort and append unique volumes
    sort -u "$volumes_tmp" >> "$output"
    rm -f "$volumes_tmp"
    
    log_success "Generated docker-compose.dynamic.yml"
}

# Generate Traefik routes
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

# Generate project containers
generate_projects() {
    log_info "Generating project containers..."
    
    local output="$ROOT_DIR/docker-compose.projects.yml"
    local projects_dir="$ROOT_DIR/projects"
    
    # Start with empty services
    echo "services:" > "$output"
    echo "" >> "$output"
    
    # Check if projects directory exists
    if [ ! -d "$projects_dir" ]; then
        log_info "No projects directory found"
        return
    fi
    
    # Process each project
    for project_path in "$projects_dir"/*; do
        [ ! -d "$project_path" ] && continue
        
        local project_name=$(basename "$project_path")
        local project_json="$project_path/stackored.json"
        
        # Skip if no stackored.json
        [ ! -f "$project_json" ] && continue
        
        log_info "Processing project: $project_name"
        
        # Parse JSON - extract values correctly
        local php_version=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_json" | head -1 | cut -d'"' -f4)
        local web_server=$(grep -o '"webserver"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_json" | cut -d'"' -f4)
        local project_domain=$(grep -o '"domain"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_json" | cut -d'"' -f4)
        
        # Default to enabled if no field (backward compat)
        local project_enabled="true"
        
        # Skip if disabled
        [ "$project_enabled" != "true" ] && continue
        
        # Generate PHP container
        cat >> "$output" <<EOF
  ${project_name}-php:
    image: "php:${php_version:-8.2}-fpm"
    container_name: "${project_name}-php"
    restart: unless-stopped
    
    volumes:
      - ${project_path}:/var/www/html
EOF
        
        # Add custom PHP config if exists
        if [ -f "$project_path/.stackored/php.ini" ]; then
            echo "      - ${project_path}/.stackored/php.ini:/usr/local/etc/php/conf.d/custom.ini:ro" >> "$output"
        fi
        
        # Add custom PHP-FPM config if exists
        if [ -f "$project_path/.stackored/php-fpm.conf" ]; then
            echo "      - ${project_path}/.stackored/php-fpm.conf:/usr/local/etc/php-fpm.d/zz-custom.conf:ro" >> "$output"
        fi
        
        cat >> "$output" <<EOF
    
    networks:
      - ${DOCKER_DEFAULT_NETWORK:-stackored-net}

EOF
        
        # Generate web server container
        if [ "$web_server" = "nginx" ]; then
            # Check for custom nginx config
            local nginx_config_mount=""
            
            if [ -f "$project_path/.stackored/nginx.conf" ]; then
                nginx_config_mount="      - ${project_path}/.stackored/nginx.conf:/etc/nginx/conf.d/default.conf:ro"
            elif [ -f "$project_path/nginx.conf" ]; then
                nginx_config_mount="      - ${project_path}/nginx.conf:/etc/nginx/conf.d/default.conf:ro"
            else
                # Use default template - generate in core/generated-configs/
                mkdir -p "$ROOT_DIR/core/generated-configs"
                local template_file="$ROOT_DIR/core/templates/nginx/default.conf"
                local generated_config="$ROOT_DIR/core/generated-configs/${project_name}-nginx.conf"
                
                # Generate config from template
                sed "s/{{PROJECT_NAME}}/${project_name}/g" "$template_file" > "$generated_config"
                nginx_config_mount="      - ${generated_config}:/etc/nginx/conf.d/default.conf:ro"
            fi
            
            cat >> "$output" <<EOF
  ${project_name}-web:
    image: "nginx:alpine"
    container_name: "${project_name}-web"
    restart: unless-stopped
    
    volumes:
      - ${project_path}:/var/www/html
EOF
            
            # Add config mount
            echo "$nginx_config_mount" >> "$output"
            
            cat >> "$output" <<EOF
    
    networks:
      - ${DOCKER_DEFAULT_NETWORK:-stackored-net}
    
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.${project_name}.rule=Host(\`${project_domain}\`)"
      - "traefik.http.routers.${project_name}.entrypoints=websecure"
      - "traefik.http.routers.${project_name}.tls=true"
      - "traefik.http.services.${project_name}.loadbalancer.server.port=80"
    
    depends_on:
      - ${project_name}-php

EOF
        elif [ "$web_server" = "apache" ]; then
            # Check for custom apache config
            local apache_config_mount=""
            
            if [ -f "$project_path/.stackored/apache.conf" ]; then
                apache_config_mount="      - ${project_path}/.stackored/apache.conf:/etc/apache2/sites-available/000-default.conf:ro"
            elif [ -f "$project_path/apache.conf" ]; then
                apache_config_mount="      - ${project_path}/apache.conf:/etc/apache2/sites-available/000-default.conf:ro"
            else
                # Use default template - generate in core/generated-configs/
                mkdir -p "$ROOT_DIR/core/generated-configs"
                local template_file="$ROOT_DIR/core/templates/apache/default.conf"
                local generated_config="$ROOT_DIR/core/generated-configs/${project_name}-apache.conf"
                
                # Copy template (no placeholders needed for Apache)
                cp "$template_file" "$generated_config"
                apache_config_mount="      - ${generated_config}:/etc/apache2/sites-available/000-default.conf:ro"
            fi
            
            cat >> "$output" <<EOF
  ${project_name}-web:
    image: "php:${php_version:-8.2}-apache"
    container_name: "${project_name}-web"
    restart: unless-stopped
    
    volumes:
      - ${project_path}:/var/www/html
EOF
            
            # Add config mount
            echo "$apache_config_mount" >> "$output"
            
            cat >> "$output" <<EOF
    
EOF
            
            # If no custom config, add command to set DocumentRoot
            if [ -z "$apache_config_mount" ]; then
                cat >> "$output" <<EOF
    command: >
      bash -c "sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' /etc/apache2/sites-available/000-default.conf &&
               sed -i '/<VirtualHost/a\    <Directory /var/www/html/public>\n        Options Indexes FollowSymLinks\n        AllowOverride All\n        Require all granted\n    </Directory>' /etc/apache2/sites-available/000-default.conf &&
               apache2-foreground"
    
EOF
            fi
            
            cat >> "$output" <<EOF
    networks:
      - ${DOCKER_DEFAULT_NETWORK:-stackored-net}
    
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.${project_name}.rule=Host(\`${project_domain}\`)"
      - "traefik.http.routers.${project_name}.entrypoints=websecure"
      - "traefik.http.routers.${project_name}.tls=true"
      - "traefik.http.services.${project_name}.loadbalancer.server.port=80"
    
    depends_on:
      - ${project_name}-php

EOF
        fi
    done
    
    log_success "Generated docker-compose.projects.yml"
}

# Main
main() {
    log_info "Stackored Generator (Bash - No PHP!)"
    cd "$ROOT_DIR"
    
    load_env
    generate_base_compose
    generate_traefik_config
    generate_traefik_routes
    generate_dynamic_compose
    generate_projects
    
    log_success "Generation completed!"
}

main "$@"
