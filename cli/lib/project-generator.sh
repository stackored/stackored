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
        
        # Parse JSON - sed kullanarak (macOS BSD awk uyumlu)
        local php_version=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$project_json")
        local web_server=$(sed -n 's/.*"webserver"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$project_json")
        local project_domain=$(sed -n 's/.*"domain"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$project_json")
        local document_root=$(sed -n 's/.*"document_root"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$project_json")
        
        # Default document_root to "public" if not specified
        if [ -z "$document_root" ]; then
            document_root="public"
        fi
        
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
                local template_file="$ROOT_DIR/$CONST_PATH_TEMPLATES/servers/nginx/default.conf"
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
                local template_file="$ROOT_DIR/core/templates/servers/apache/default.conf"
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
        elif [ "$web_server" = "caddy" ]; then
            # Check for custom caddy config
            local caddy_config_mount=""
            
            if [ -f "$project_path/.stackored/Caddyfile" ]; then
                caddy_config_mount="      - ${project_path}/.stackored/Caddyfile:/etc/caddy/Caddyfile:ro"
            elif [ -f "$project_path/Caddyfile" ]; then
                caddy_config_mount="      - ${project_path}/Caddyfile:/etc/caddy/Caddyfile:ro"
            else
                # Use default template - generate in core/generated-configs/
                mkdir -p "$ROOT_DIR/core/generated-configs"
                local template_file="$ROOT_DIR/core/templates/servers/caddy/Caddyfile"
                local generated_config="$ROOT_DIR/core/generated-configs/${project_name}-caddy.conf"
                
                # Generate config from template
                sed -e "s/{{PROJECT_NAME}}/${project_name}/g" \
                    -e "s|{{DOCUMENT_ROOT}}|${document_root}|g" \
                    "$template_file" > "$generated_config"
                caddy_config_mount="      - ${generated_config}:/etc/caddy/Caddyfile:ro"
            fi
            
            cat >> "$output" <<EOF
  ${project_name}-web:
    image: "caddy:latest"
    container_name: "${project_name}-web"
    restart: unless-stopped
    
    volumes:
      - ${project_path}:/var/www/html
EOF
            
            # Add config mount
            echo "$caddy_config_mount" >> "$output"
            
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
        elif [ "$web_server" = "ferron" ]; then
            # Check for custom ferron config
            local ferron_config_mount=""
            
            # Ferron YAML config için (.stackored/ferron.yaml veya ferron.yaml)
            if [ -f "$project_path/.stackored/ferron.yaml" ]; then
                ferron_config_mount="      - ${project_path}/.stackored/ferron.yaml:/etc/ferron/conf.d/default.yaml:ro"
            elif [ -f "$project_path/ferron.yaml" ]; then
                ferron_config_mount="      - ${project_path}/ferron.yaml:/etc/ferron/conf.d/default.yaml:ro"
            # Eski .conf formatı için backward compatibility
            elif [ -f "$project_path/.stackored/ferron.conf" ]; then
                ferron_config_mount="      - ${project_path}/.stackored/ferron.conf:/etc/ferron/conf.d/default.yaml:ro"
            elif [ -f "$project_path/ferron.conf" ]; then
                ferron_config_mount="      - ${project_path}/ferron.conf:/etc/ferron/conf.d/default.yaml:ro"
            else
                # Use default YAML template - generate in core/generated-configs/
                mkdir -p "$ROOT_DIR/core/generated-configs"
                local template_file="$ROOT_DIR/core/templates/servers/ferron/ferron.yaml"
                local generated_config="$ROOT_DIR/core/generated-configs/${project_name}-ferron.yaml"
                
                # Generate config from template
                sed -e "s/{{PROJECT_NAME}}/${project_name}/g" \
                    -e "s|{{DOCUMENT_ROOT}}|${document_root}|g" \
                    "$template_file" > "$generated_config"
                ferron_config_mount="      - ${generated_config}:/etc/ferron/conf.d/default.yaml:ro"
            fi
            
            cat >> "$output" <<EOF
  ${project_name}-web:
    image: "ferronserver/ferron:latest"
    container_name: "${project_name}-web"
    restart: unless-stopped
    
    volumes:
      - ${project_path}:/var/www/html
EOF
            
            # Add config mount
            echo "$ferron_config_mount" >> "$output"
            
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
