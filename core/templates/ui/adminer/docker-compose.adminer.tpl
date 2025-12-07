###################################################################
# STACKORED ADMINER COMPOSE TEMPLATE
###################################################################

services:
  adminer:
    image: "adminer:{{ ADMINER_VERSION }}"
    container_name: "stackored-adminer"
    restart: unless-stopped

    environment:
      ADMINER_DESIGN: "{{ ADMINER_DESIGN | default('pepa-linde-dark') }}"

    ports:
      - "{{ HOST_PORT_ADMINER | default('8080') }}:8080"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"
