  {{ PROJECT_NAME }}-web:
    image: "php:{{ PHP_VERSION }}-apache"
    container_name: "{{ PROJECT_NAME }}-web"
    restart: unless-stopped
    
    working_dir: /var/www/html
    
    volumes:
      - ./projects/{{ PROJECT_NAME }}:/var/www/html
    
    command: >
      bash -c "
      sed -i 's|/var/www/html|/var/www/html/{{ DOCUMENT_ROOT }}|g' /etc/apache2/sites-available/000-default.conf &&
      apache2-foreground
      "
    
    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"
