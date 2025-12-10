#!/bin/bash
###################################################################
# STACKORED COMPOSE GENERATOR MODULE
# Docker Compose dosyaları üretme
###################################################################

##
# Base stackored.yml dosyasını üretir (Traefik ve network)
#
# Returns:
#   0 - Başarılı
##
generate_base_compose() {
    log_info "Generating stackored.yml (base compose)..."
    
    local output="$ROOT_DIR/stackored.yml"
    local template="$ROOT_DIR/core/compose/base.yml"
    
    if [ -f "$template" ]; then
        if ! render_template "$template" > "$output" 2>/dev/null; then
            log_error "Failed to generate stackored.yml from template"
            return 1
        fi
    else
        # Fallback: create minimal base compose
        if ! cat > "$output" <<'EOF'
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
        then
            log_error "Failed to create stackored.yml"
            return 1
        fi
    fi
    
    log_success "Generated stackored.yml"
}

##
# Dynamic docker-compose.dynamic.yml dosyasını üretir (servisler)
#
# Returns:
#   0 - Başarılı
##
generate_dynamic_compose() {
    log_info "Generating docker-compose.dynamic.yml..."
    
    local output="$ROOT_DIR/docker-compose.dynamic.yml"
    
    if ! echo "services:" > "$output" 2>/dev/null; then
        log_error "Failed to create docker-compose.dynamic.yml"
        return 1
    fi
    
    echo "" >> "$output"
    
    # Databases
    include_module "MYSQL_ENABLE" "modules/mysql/docker-compose.mysql.tpl" >> "$output"
    include_module "MARIADB_ENABLE" "modules/mariadb/docker-compose.mariadb.tpl" >> "$output"
    include_module "POSTGRES_ENABLE" "modules/postgres/docker-compose.postgres.tpl" >> "$output"
    include_module "MONGO_ENABLE" "modules/mongo/docker-compose.mongo.tpl" >> "$output"
    include_module "CASSANDRA_ENABLE" "modules/cassandra/docker-compose.cassandra.tpl" >> "$output"
    include_module "PERCONA_ENABLE" "modules/percona/docker-compose.percona.tpl" >> "$output"
    include_module "COUCHDB_ENABLE" "modules/couchdb/docker-compose.couchdb.tpl" >> "$output"
    include_module "COUCHBASE_ENABLE" "modules/couchbase/docker-compose.couchbase.tpl" >> "$output"
    
    # Caching
    include_module "REDIS_ENABLE" "modules/redis/docker-compose.redis.tpl" >> "$output"
    include_module "MEMCACHED_ENABLE" "modules/memcached/docker-compose.memcached.tpl" >> "$output"
    
    # Message Queues
    include_module "RABBITMQ_ENABLE" "modules/rabbitmq/docker-compose.rabbitmq.tpl" >> "$output"
    include_module "NATS_ENABLE" "modules/nats/docker-compose.nats.tpl" >> "$output"
    include_module "KAFKA_ENABLE" "modules/kafka/docker-compose.kafka.tpl" >> "$output"
    include_module "KAFBAT_ENABLE" "modules/kafbat/docker-compose.kafbat.tpl" >> "$output"
    include_module "ACTIVEMQ_ENABLE" "modules/activemq/docker-compose.activemq.tpl" >> "$output"
    
    # Search
    include_module "ELASTICSEARCH_ENABLE" "modules/elasticsearch/docker-compose.elasticsearch.tpl" >> "$output"
    include_module "MEILISEARCH_ENABLE" "modules/meilisearch/docker-compose.meilisearch.tpl" >> "$output"
    include_module "SOLR_ENABLE" "modules/solr/docker-compose.solr.tpl" >> "$output"
    
    # Monitoring
    include_module "KIBANA_ENABLE" "modules/kibana/docker-compose.kibana.tpl" >> "$output"
    include_module "GRAFANA_ENABLE" "modules/grafana/docker-compose.grafana.tpl" >> "$output"
    include_module "LOGSTASH_ENABLE" "modules/logstash/docker-compose.logstash.tpl" >> "$output"
    include_module "NETDATA_ENABLE" "modules/netdata/docker-compose.netdata.tpl" >> "$output"
    
    # QA
    include_module "SONARQUBE_ENABLE" "modules/sonarqube/docker-compose.sonarqube.tpl" >> "$output"
    include_module "SENTRY_ENABLE" "modules/sentry/docker-compose.sentry.tpl" >> "$output"
    include_module "BLACKFIRE_ENABLE" "modules/blackfire/docker-compose.blackfire.tpl" >> "$output"
    
    # App Servers
    include_module "TOMCAT_ENABLE" "modules/tomcat/docker-compose.tomcat.tpl" >> "$output"
    include_module "KONG_ENABLE" "modules/kong/docker-compose.kong.tpl" >> "$output"
    
    # Tools
    include_module "MAILHOG_ENABLE" "modules/mailhog/docker-compose.mailhog.tpl" >> "$output"
    include_module "COMPOSER_ENABLE" "tools/composer/docker-compose.composer.tpl" >> "$output"
    include_module "NGROK_ENABLE" "modules/ngrok/docker-compose.ngrok.tpl" >> "$output"
    include_module "SELENIUM_ENABLE" "modules/selenium/docker-compose.selenium.tpl" >> "$output"
    include_module "TOOLS_CONTAINER_ENABLE" "ui/tools/docker-compose.tools.tpl" >> "$output"
    
    # Stackored Web UI
    include_module "STACKORED_UI_ENABLE" "ui/stackored-ui/docker-compose.stackored-ui.tpl" >> "$output"
    
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
