  {{ PROJECT_NAME }}-php:
    image: "php:{{ PHP_VERSION }}-fpm-alpine"
    container_name: "{{ PROJECT_NAME }}-php"
    restart: unless-stopped
    
    working_dir: /var/www/html
    
    volumes:
      - ./projects/{{ PROJECT_NAME }}:/var/www/html
    
    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

  {{ PROJECT_NAME }}-web:
    image: "nginx:alpine"
    container_name: "{{ PROJECT_NAME }}-web"
    restart: unless-stopped
    
    volumes:
      - ./projects/{{ PROJECT_NAME }}:/var/www/html
      - ./projects/{{ PROJECT_NAME }}/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    
    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"
    
    depends_on:
      - "{{ PROJECT_NAME }}"-php
