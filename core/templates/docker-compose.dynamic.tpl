version: "3.9"

###################################################################
# AUTO-GENERATED DYNAMIC COMPOSE
# Includes all enabled modules and all project containers.
###################################################################

services:
{% for project in PROJECTS %}
{{ project.slug }}:
container_name: "{{ project.slug }}"
build:
context: "{{ project.path }}"
dockerfile: "{{ project.dockerfile }}"
volumes:
- "{{ project.path }}:/var/www/html"
environment:
- "PROJECT_NAME={{ project.name }}"
labels:
- "traefik.enable=true"
- "traefik.http.routers.{{ project.slug }}.rule=Host(`{{ project.domain }}`)"
- "traefik.http.services.{{ project.slug }}.loadbalancer.server.port=9000"
networks:
- "{{ DOCKER_DEFAULT_NETWORK }}"
{% endfor %}

{% if ENABLE_MYSQL == "true" %}
mysql:
image: mysql:{{ MYSQL_VERSION }}
environment:
MYSQL_ROOT_PASSWORD: "root"
networks:
- "{{ DOCKER_DEFAULT_NETWORK }}"
{% endif %}

{% if ENABLE_REDIS == "true" %}
redis:
image: redis:{{ REDIS_VERSION }}
networks:
- "{{ DOCKER_DEFAULT_NETWORK }}"
{% endif %}

networks:
{{ DOCKER_DEFAULT_NETWORK }}:
external: true
