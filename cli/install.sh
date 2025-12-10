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

# Check and update Docker Compose version
check_docker_compose_version() {
    log_info "Checking Docker Compose version..."
    
    # Get current version
    local current_version=$(docker compose version 2>/dev/null | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [ -z "$current_version" ]; then
        log_error "Docker Compose not found! Please install Docker Compose first."
        exit 1
    fi
    
    log_info "Current Docker Compose version: v$current_version"
    
    # Get latest version from GitHub
    local latest_version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    if [ -z "$latest_version" ]; then
        log_warn "Could not fetch latest Docker Compose version. Continuing with current version..."
        return
    fi
    
    log_info "Latest Docker Compose version: v$latest_version"
    
    # Compare versions (simple major.minor comparison)
    local current_major=$(echo "$current_version" | cut -d. -f1)
    local latest_major=$(echo "$latest_version" | cut -d. -f1)
    
    # Minimum recommended version is 3.0.0 (to avoid concurrent map writes bug)
    local min_major=3
    
    if [ "$current_major" -lt "$min_major" ]; then
        log_warn "⚠️  Your Docker Compose version (v$current_version) is outdated!"
        log_warn "   Minimum recommended version: v${min_major}.0.0"
        log_warn "   Latest version: v$latest_version"
        echo ""
        echo "   The old version has a 'concurrent map writes' bug that causes issues."
        echo "   Updating automatically..."
        echo ""
        
        log_info "Updating Docker Compose to v$latest_version..."
        
        # Download and install
        if sudo curl -L "https://github.com/docker/compose/releases/download/v${latest_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 2>/dev/null; then
            sudo chmod +x /usr/local/bin/docker-compose
            log_success "Docker Compose updated to v$latest_version"
        else
            log_error "Failed to update Docker Compose. Please update manually."
            log_info "Run: sudo curl -L \"https://github.com/docker/compose/releases/download/v${latest_version}/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
            exit 1
        fi
    else
        log_success "Docker Compose version is sufficient (v$current_version >= v${min_major}.0.0)"
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

