#!/bin/bash
###################################################################
# Stackored SSL Certificate Generator with mkcert
# Generates trusted SSL certificates for local development
# Auto-installs mkcert if not present
###################################################################

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CERT_DIR="$ROOT_DIR/core/certs"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[OK]${NC} $1" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1" >&2; }

# Check if mkcert is installed, install if not
check_mkcert() {
    if command -v mkcert &> /dev/null; then
        log_success "mkcert is already installed"
        return 0
    fi
    
    log_warn "mkcert is not installed. Installing automatically..."
    
    # Detect OS
    local os_type=""
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os_type="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macos"
    else
        log_error "Unsupported OS: $OSTYPE"
        echo "Please install mkcert manually from: https://github.com/FiloSottile/mkcert" >&2
        exit 1
    fi
    
    if [ "$os_type" = "linux" ]; then
        log_info "Installing mkcert for Linux..."
        
        # Install dependencies
        if command -v apt-get &> /dev/null; then
            log_info "Installing libnss3-tools..."
            sudo apt-get update -qq
            sudo apt-get install -y libnss3-tools
        elif command -v yum &> /dev/null; then
            log_info "Installing nss-tools..."
            sudo yum install -y nss-tools
        fi
        
        # Download and install mkcert
        local mkcert_version="v1.4.4"
        local mkcert_url="https://github.com/FiloSottile/mkcert/releases/download/${mkcert_version}/mkcert-${mkcert_version}-linux-amd64"
        
        log_info "Downloading mkcert ${mkcert_version}..."
        wget -q "$mkcert_url" -O /tmp/mkcert
        
        log_info "Installing to /usr/local/bin/mkcert..."
        sudo mv /tmp/mkcert /usr/local/bin/mkcert
        sudo chmod +x /usr/local/bin/mkcert
        
        log_success "mkcert installed successfully!"
        
    elif [ "$os_type" = "macos" ]; then
        log_info "Installing mkcert for macOS..."
        
        if command -v brew &> /dev/null; then
            brew install mkcert
            log_success "mkcert installed successfully!"
        else
            log_error "Homebrew is not installed. Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" >&2
            exit 1
        fi
    fi
    
    # Install CA
    log_info "Installing mkcert CA to system trust store..."
    mkcert -install
    
    log_success "✅ mkcert setup completed!"
}

# Collect all domains from projects
collect_domains() {
    local domains=()
    
    # Base domains
    domains+=("stackored.loc")
    domains+=("*.stackored.loc")
    
    # Scan projects directory for stackored.json files
    if [ -d "$ROOT_DIR/projects" ]; then
        for project_path in "$ROOT_DIR/projects"/*; do
            [ ! -d "$project_path" ] && continue
            
            local project_json="$project_path/stackored.json"
            [ ! -f "$project_json" ] && continue
            
            # Extract domain from JSON
            local domain=$(grep -o '"domain"[[:space:]]*:[[:space:]]*"[^"]*"' "$project_json" | cut -d'"' -f4)
            
            if [ -n "$domain" ]; then
                domains+=("$domain")
            fi
        done
    fi
    
    # Return domains as space-separated string
    echo "${domains[@]}"
}

# Generate certificates with mkcert
generate_certificates() {
    log_info "🔐 Generating SSL Certificates with mkcert..."
    
    # Create cert directory
    mkdir -p "$CERT_DIR"
    
    # Collect all domains
    local domains=($(collect_domains))
    
    if [ ${#domains[@]} -eq 0 ]; then
        log_error "No domains found!"
        exit 1
    fi
    
    log_info "Generating certificates for ${#domains[@]} domain(s):"
    for domain in "${domains[@]}"; do
        echo "  - $domain" >&2
    done
    echo "" >&2
    
    # Generate certificate with mkcert
    cd "$CERT_DIR"
    
    # Remove old certificates
    rm -f stackored-wildcard.crt stackored-wildcard.key
    
    # Generate new certificate for all domains
    mkcert -cert-file stackored-wildcard.crt \
           -key-file stackored-wildcard.key \
           "${domains[@]}"
    
    # Copy CA certificate for reference
    local ca_location=$(mkcert -CAROOT)
    if [ -f "$ca_location/rootCA.pem" ]; then
        cp "$ca_location/rootCA.pem" "$CERT_DIR/stackored-ca.crt"
        log_info "CA certificate copied from: $ca_location"
    fi
    
    cd "$ROOT_DIR"
    
    log_success "✅ SSL Certificates generated successfully!"
}

# Display certificate info
show_certificate_info() {
    echo "" >&2
    echo "📁 Generated files:" >&2
    echo "   - $CERT_DIR/stackored-wildcard.crt (SSL Certificate)" >&2
    echo "   - $CERT_DIR/stackored-wildcard.key (Private Key)" >&2
    echo "   - $CERT_DIR/stackored-ca.crt (CA Certificate - for reference)" >&2
    echo "" >&2
    
    # Show certificate details
    if command -v openssl &> /dev/null; then
        log_info "Certificate details:"
        openssl x509 -in "$CERT_DIR/stackored-wildcard.crt" -noout -text | grep -A 1 "Subject:" >&2
        echo "" >&2
        log_info "Valid domains (SAN):"
        openssl x509 -in "$CERT_DIR/stackored-wildcard.crt" -noout -text | grep -A 10 "Subject Alternative Name" | grep DNS >&2
        echo "" >&2
    fi
    
    log_success "📌 Certificates are trusted by your system!"
    echo "" >&2
    echo "Next steps:" >&2
    echo "   1. Run: stackored down" >&2
    echo "   2. Run: stackored up" >&2
    echo "   3. Access: https://traefik.stackored.loc" >&2
    echo "" >&2
    echo "No browser warnings! 🎉" >&2
}

# Main
main() {
    echo "🔐 Stackored SSL Certificate Generator (mkcert)" >&2
    echo "" >&2
    
    check_mkcert
    generate_certificates
    show_certificate_info
}

main "$@"
