#!/usr/bin/env bash

# Global sabitler
readonly STACKORED_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Logger kütüphanesini yükle
source "$(dirname "${BASH_SOURCE[0]}")/lib/logger.sh"



# Update /etc/hosts with stackored domains
update_hosts_file() {
    log_info "Checking /etc/hosts configuration..."
    
    # Check if stackored domains already exist
    if grep -q "stackored.loc" /etc/hosts 2>/dev/null; then
        log_success "/etc/hosts already configured"
        return
    fi
    
    log_info "Adding stackored domains to /etc/hosts..."
    
    # Create hosts entries
    cat > /tmp/stackored-hosts << 'EOF'

# Stackored Domains
127.0.0.1 traefik.stackored.loc
127.0.0.1 activemq.stackored.loc
127.0.0.1 elasticsearch.stackored.loc
127.0.0.1 grafana.stackored.loc
127.0.0.1 kafbat.stackored.loc
127.0.0.1 kibana.stackored.loc
127.0.0.1 kong.stackored.loc
127.0.0.1 mailhog.stackored.loc
127.0.0.1 mariadb.stackored.loc
127.0.0.1 meilisearch.stackored.loc
127.0.0.1 mongo.stackored.loc
127.0.0.1 mysql.stackored.loc
127.0.0.1 netdata.stackored.loc
127.0.0.1 postgres.stackored.loc
127.0.0.1 rabbitmq.stackored.loc
127.0.0.1 redis.stackored.loc
127.0.0.1 sentry.stackored.loc
127.0.0.1 sonarqube.stackored.loc
127.0.0.1 tomcat.stackored.loc
127.0.0.1 tools.stackored.loc
127.0.0.1 adminer.stackored.loc
127.0.0.1 phpmyadmin.stackored.loc
127.0.0.1 phppgadmin.stackored.loc
127.0.0.1 phpmemcachedadmin.stackored.loc
127.0.0.1 phpmongo.stackored.loc
127.0.0.1 opcache.stackored.loc
127.0.0.1 project1.stackored.loc
127.0.0.1 project2.stackored.loc
127.0.0.1 project3.stackored.loc
EOF
    
    # Append to /etc/hosts with sudo
    if sudo bash -c 'cat /tmp/stackored-hosts >> /etc/hosts'; then
        rm /tmp/stackored-hosts
        log_success "Added stackored domains to /etc/hosts"
    else
        log_warn "Failed to update /etc/hosts. You may need to add domains manually."
        rm /tmp/stackored-hosts
    fi
}

# Check Docker Compose version
check_docker_compose_version() {
    log_info "Checking Docker Compose version..."
    
    # Get current version
    local current_version=$(docker compose version 2>/dev/null | sed -E 's/.*v([0-9]+\.[0-9]+\.[0-9]+).*/\1/' | head -1)
    
    if [ -z "$current_version" ]; then
        log_error "Docker Compose not found! Please install Docker Compose first."
        log_info "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    log_info "Current Docker Compose version: v$current_version"
    
    # Extract major and minor version
    local current_major=$(echo "$current_version" | cut -d. -f1)
    local current_minor=$(echo "$current_version" | cut -d. -f2)
    
    # Minimum recommended version is 2.0.0 (Docker Compose v2 series)
    local min_major=2
    local min_minor=0
    
    if [ "$current_major" -lt "$min_major" ] || ([ "$current_major" -eq "$min_major" ] && [ "$current_minor" -lt "$min_minor" ]); then
        log_error "⚠️  Your Docker Compose version (v$current_version) is too old!"
        log_error "   Minimum required version: v${min_major}.${min_minor}.0"
        echo ""
        echo "   Please update Docker Compose manually:"
        echo "   - macOS: Update Docker Desktop from https://www.docker.com/products/docker-desktop"
        echo "   - Linux: Visit https://docs.docker.com/compose/install/"
        echo ""
        exit 1
    else
        log_success "Docker Compose version is sufficient (v$current_version >= v${min_major}.${min_minor}.0)"
    fi
}

echo "🔧 Stackored CLI Kuruluyor..."

# Check Docker Compose version first
check_docker_compose_version

# Update /etc/hosts
update_hosts_file

# Make scripts executable
chmod +x "$STACKORED_ROOT/stackored/cli/stackored.sh"
chmod +x "$STACKORED_ROOT/stackored/cli/generate.sh"
chmod +x "$STACKORED_ROOT/stackored/cli/generate-ssl-certs.sh"
chmod +x "$STACKORED_ROOT/stackored/cli/uninstall.sh"

# Create symlink
sudo ln -sf "$STACKORED_ROOT/stackored/cli/stackored.sh" /usr/local/bin/stackored

echo ""
log_success "Kurulum tamamlandı. Komut kullanılabilir:"
echo "   stackored generate"
echo "   stackored up"
echo ""

