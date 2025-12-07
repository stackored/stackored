###################################################################
# STACKORED MAILHOG COMPOSE TEMPLATE
###################################################################

services:
  mailhog:
    image: "mailhog/mailhog:{{ MAILHOG_VERSION }}"
    container_name: "stackored-mailhog"
    restart: unless-stopped

    ports:
      - "{{ HOST_PORT_MAILHOG_SMTP | default('1025') }}:1025"
      - "{{ HOST_PORT_MAILHOG_UI | default('8025') }}:8025"

    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}
