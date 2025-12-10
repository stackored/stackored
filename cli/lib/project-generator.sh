#!/bin/bash
###################################################################
# STACKORED PROJECT GENERATOR MODULE
# Proje container'ları üretme
###################################################################

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
        if [ ! -f "$project_json" ]; then
            log_warn "Skipping $project_name: stackored.json not found"
            continue
        fi
        
        log_info "Processing project: $project_name"
        
        # Parse JSON - tek awk ile tüm değerleri çıkar (optimize edildi)
        # 3 ayrı grep+cut yerine tek awk kullanımı
        local json_values
        json_values=$(awk '
            /"version"[[:space:]]*:[[:space:]]*"/ { 
                match($0, /"version"[[:space:]]*:[[:space:]]*"([^"]*)"/, arr)
                version = arr[1]
            }
            /"webserver"[[:space:]]*:[[:space:]]*"/ { 
                match($0, /"webserver"[[:space:]]*:[[:space:]]*"([^"]*)"/, arr)
                webserver = arr[1]
            }
            /"domain"[[:space:]]*:[[:space:]]*"/ { 
                match($0, /"domain"[[:space:]]*:[[:space:]]*"([^"]*)"/, arr)
                domain = arr[1]
            }
            END {
                print version "|" webserver "|" domain
            }
        ' "$project_json")
        
        # Split values
        local php_version="${json_values%%|*}"
        local temp="${json_values#*|}"
        local web_server="${temp%%|*}"
        local project_domain="${temp#*|}"
        
        # Validate and set defaults for missing values
        if [ -z "$php_version" ]; then
            log_warn "PHP version not found in $project_json, using default: ${DEFAULT_PHP_VERSION:-$CONST_DEFAULT_PHP_VERSION}"
            php_version="${DEFAULT_PHP_VERSION:-$CONST_DEFAULT_PHP_VERSION}"
        fi
        
        if [ -z "$web_server" ]; then
            log_warn "Webserver not found in $project_json, using default: ${DEFAULT_WEBSERVER:-$CONST_DEFAULT_WEBSERVER}"
            web_server="${DEFAULT_WEBSERVER:-$CONST_DEFAULT_WEBSERVER}"
        fi
        
        if [ -z "$project_domain" ]; then
            log_error "Domain not found in $project_json for project $project_name"
            log_error "Skipping project $project_name"
            continue
        fi
        
        # Default to enabled if no field (backward compat)
        local project_enabled="true"
        
        # Skip if disabled
        [ "$project_enabled" != "true" ] && continue
        
        # Generate PHP container
        cat >> "$output" <<EOF
  ${project_name}-php:
    image: "php:${php_version:-$CONST_DEFAULT_PHP_VERSION}-fpm"
    container_name: "${project_name}-php"
    restart: unless-stopped
    
    volumes:
      - ${project_path}:/var/www/html
EOF
        
        # Add custom PHP config if exists
        if [ -f "$project_path/$CONST_STACKORED_CONFIG_DIR/$CONST_CONFIG_PHP_INI" ]; then
            echo "      - ${project_path}/$CONST_STACKORED_CONFIG_DIR/$CONST_CONFIG_PHP_INI:/usr/local/etc/php/conf.d/custom.ini:ro" >> "$output"
        fi
        
        # Add custom PHP-FPM config if exists
        if [ -f "$project_path/$CONST_STACKORED_CONFIG_DIR/$CONST_CONFIG_PHP_FPM" ]; then
            echo "      - ${project_path}/$CONST_STACKORED_CONFIG_DIR/$CONST_CONFIG_PHP_FPM:/usr/local/etc/php-fpm.d/zz-custom.conf:ro" >> "$output"
        fi
        
        cat >> "$output" <<EOF
    
    networks:
      - ${DOCKER_DEFAULT_NETWORK:-$CONST_DEFAULT_NETWORK}

EOF
        
        # Generate web server container
        if [ "$web_server" = "$CONST_DEFAULT_WEBSERVER" ] || [ "$web_server" = "nginx" ]; then
            # Check for custom nginx config
            local nginx_config_mount=""
            
            if [ -f "$project_path/$CONST_STACKORED_CONFIG_DIR/$CONST_CONFIG_NGINX" ]; then
                nginx_config_mount="      - ${project_path}/$CONST_STACKORED_CONFIG_DIR/$CONST_CONFIG_NGINX:/etc/nginx/conf.d/default.conf:ro"
            elif [ -f "$project_path/$CONST_CONFIG_NGINX" ]; then
                nginx_config_mount="      - ${project_path}/$CONST_CONFIG_NGINX:/etc/nginx/conf.d/default.conf:ro"
            else
                # Use default template - generate in core/generated-configs/
                mkdir -p "$ROOT_DIR/$CONST_PATH_GENERATED_CONFIGS"
                local template_file="$ROOT_DIR/$CONST_PATH_TEMPLATES/nginx/default.conf"
                local generated_config="$ROOT_DIR/$CONST_PATH_GENERATED_CONFIGS/${project_name}-nginx.conf"
                
                # Generate config from template
                sed "s/{{PROJECT_NAME}}/${project_name}/g" "$template_file" > "$generated_config"
                nginx_config_mount="      - ${generated_config}:/etc/nginx/conf.d/default.conf:ro"
            fi
            
            cat >> "$output" <<EOF
  ${project_name}-web:
    image: "$CONST_IMAGE_NGINX"
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
