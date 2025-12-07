###################################################################
# STACKORED BLACKFIRE AGENT COMPOSE TEMPLATE
###################################################################

services:
  blackfire:
    image: "blackfire/blackfire:{{ BLACKFIRE_VERSION }}"
    container_name: "stackored-blackfire"
    restart: unless-stopped

    environment:
      BLACKFIRE_SERVER_ID: "{{ BLACKFIRE_SERVER_ID }}"
      BLACKFIRE_SERVER_TOKEN: "{{ BLACKFIRE_SERVER_TOKEN }}"
      BLACKFIRE_LOG_LEVEL: "{{ BLACKFIRE_LOG_LEVEL | default('1') }}"

    ports:
      - "{{ HOST_PORT_BLACKFIRE | default('8707') }}:8707"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"
