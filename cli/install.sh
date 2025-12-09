#!/usr/bin/env bash

STACKORED_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

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

echo "🔧 Stackored CLI Kuruluyor..."

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

