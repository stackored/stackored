#!/bin/bash
set -eo pipefail

###################################################################
# STACKORED GENERATOR - PURE BASH IMPLEMENTATION
# Compatible with Bash 3.x+ (macOS default)
# No PHP dependency required!
#
# Bu dosya sadece orchestrator görevi görür.
# Tüm fonksiyonlar modüllere ayrılmıştır.
###################################################################

# Global sabitler
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Kütüphaneleri yükle
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/env-loader.sh"
source "$SCRIPT_DIR/lib/template-processor.sh"
source "$SCRIPT_DIR/lib/config-generator.sh"
source "$SCRIPT_DIR/lib/compose-generator.sh"
source "$SCRIPT_DIR/lib/traefik-generator.sh"
source "$SCRIPT_DIR/lib/project-generator.sh"

##
# Ana orchestrator fonksiyonu
# Tüm generator modüllerini sırayla çalıştırır
##
main() {
    log_info "Stackored Generator (Bash - No PHP!)"
    cd "$ROOT_DIR"
    
    # Environment yükle
    load_env
    
    # Generate module configs
    generate_module_configs
    
    # Compose dosyalarını üret
    generate_base_compose
    generate_traefik_config
    generate_traefik_routes
    generate_dynamic_compose
    generate_projects
    
    log_success "Generation completed!"
}

# Ana fonksiyonu çalıştır
main "$@"
