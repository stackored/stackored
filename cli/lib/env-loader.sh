#!/bin/bash
###################################################################
# STACKORED ENV LOADER MODULE
# Environment değişkenlerini yükleme
###################################################################

##
# .env dosyasını yükler ve environment değişkenlerini export eder
#
# Returns:
#   0 - Başarılı
#   1 - .env dosyası bulunamadı
##
load_env() {
    log_info "Loading environment..."
    
    if [ ! -f "$ROOT_DIR/.env" ]; then
        log_error ".env not found"
        exit 1
    fi
    
    set -a
    source "$ROOT_DIR/.env"
    set +a
}
