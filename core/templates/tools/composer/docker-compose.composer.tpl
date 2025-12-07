###################################################################
# STACKORED COMPOSER COMPOSE TEMPLATE
###################################################################

services:
  composer:
    image: "composer:{{ COMPOSER_VERSION }}"
    container_name: "stackored-composer"
    restart: "no"

    working_dir: /app

    volumes:
      - ./:/app
      - stackored-composer-cache:/tmp

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

    command: ["composer", "--version"]

    environment:
      COMPOSER_ALLOW_SUPERUSER: "{{ COMPOSER_ALLOW_SUPERUSER | default('1') }}"
      COMPOSER_MEMORY_LIMIT: "{{ COMPOSER_MEMORY_LIMIT | default('-1') }}"

volumes:
  stackored-composer-cache:
