version: "3.9"

###################################################################
# PROJECT COMPOSE TEMPLATE (Overrideable via .stackored/)
###################################################################

services:
app:
build:
context: "{{ PROJECT_PATH }}"
dockerfile: "{{ DOCKERFILE_PATH }}"
container_name: "{{ PROJECT_SLUG }}"
environment:
APP_NAME: "{{ PROJECT_NAME }}"
PHP_VERSION: "{{ PROJECT_PHP }}"
volumes:
- "{{ PROJECT_PATH }}:/var/www/html"
labels:
- "traefik.enable=true"
- "traefik.http.routers.{{ PROJECT_SLUG }}.rule=Host(`{{ PROJECT_DOMAIN }}`)"
- "traefik.http.services.{{ PROJECT_SLUG }}.loadbalancer.server.port=9000"
networks:
- "{{ DOCKER_DEFAULT_NETWORK }}"

networks:
{{ DOCKER_DEFAULT_NETWORK }}:
external: true
