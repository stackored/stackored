#!/bin/bash
###################################################################
# STACKORED TEMPLATE PROCESSOR MODULE
# Template rendering ve modül dahil etme
###################################################################

##
# Template dosyasını render eder ({{ VAR }} → ${VAR} dönüşümü)
#
# Args:
#   $1 - Template dosya yolu
#
# Returns:
#   0 - Başarılı
#   1 - Template dosyası bulunamadı
##
render_template() {
    local template_file=$1
    
    if [ ! -f "$template_file" ]; then
        log_error "Template file not found: $template_file"
        return 1
    fi
    
    # Optimize edildi: sed ve envsubst tek pipeline'da
    # {{ VAR }} → ${VAR} ve {{ VAR | default('x') }} → ${VAR:-x} dönüşümü
    local rendered_content
    rendered_content=$(sed \
        -e 's/{{[[:space:]]*\([A-Z0-9_]*\)[[:space:]]*}}/${\1}/g' \
        -e "s/{{[[:space:]]*\([A-Z0-9_]*\)[[:space:]]*|[[:space:]]*default('\([^']*\)')[[:space:]]*}}/\${\1:-\2}/g" \
        -e "s/{{[[:space:]]*\([A-Z0-9_]*\)[[:space:]]*|[[:space:]]*default(\"\([^\"]*\)\")[[:space:]]*}}/\${\1:-\2}/g" \
        "$template_file" 2>/dev/null | envsubst 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$rendered_content" ]; then
        log_error "Failed to render template: $template_file"
        return 1
    fi
    
    echo "$rendered_content"
}

##
# Modül template'ini işler ve compose dosyasına ekler (eğer enabled ise)
#
# Args:
#   $1 - Enable değişken adı (örn: MYSQL_ENABLE)
#   $2 - Template dosya yolu (örn: database/mysql/docker-compose.mysql.tpl)
#
# Returns:
#   0 - Başarılı veya disabled
#   1 - Template bulunamadı
##
include_module() {
    local enable_var=$1
    local template_path=$2
    local full_path="$ROOT_DIR/core/templates/$template_path"
    
    # Check if enabled
    eval "local enabled=\${${enable_var}:-false}"
    
    if [ "$enabled" = "true" ]; then
        if [ ! -f "$full_path" ]; then
            log_warn "Template not found for $enable_var: $full_path"
            return 1
        fi
        
        log_info "Including: $enable_var"
        
        # Process template and extract only service definitions
        # Skip: comments (#), "services:" line, "volumes:" section
        # Fix: indentation for ports/networks and their list items
        local rendered_output
        rendered_output=$(render_template "$full_path")
        
        if [ $? -ne 0 ] || [ -z "$rendered_output" ]; then
            log_error "Failed to render template for $enable_var"
            return 1
        fi
        
        echo "$rendered_output" | \
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
