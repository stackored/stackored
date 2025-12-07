###################################################################
# STACKORED NATS COMPOSE TEMPLATE
###################################################################

services:
  nats:
    image: "nats:{{ NATS_VERSION }}"
    container_name: "stackored-nats"
    restart: unless-stopped

    command: >
      -js
      -m 8222
      --max_payload 1048576
      {{ NATS_EXTRA_ARGS | default('') }}

    ports:
      - "{{ HOST_PORT_NATS | default('4222') }}:4222"  # Client port
      - "{{ HOST_PORT_NATS_MONITORING | default('8222') }}:8222" # Monitoring
      - "{{ HOST_PORT_NATS_CLUSTER | default('6222') }}:6222" # Clustering

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

volumes:
  stackored-nats-data:
