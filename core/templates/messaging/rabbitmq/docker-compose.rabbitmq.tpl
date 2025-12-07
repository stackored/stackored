###################################################################
# STACKORED RABBITMQ COMPOSE TEMPLATE
###################################################################

services:
  rabbitmq:
    image: "rabbitmq:{{ RABBITMQ_VERSION }}-management"
    container_name: "stackored-rabbitmq"
    restart: unless-stopped

    environment:
      RABBITMQ_DEFAULT_USER: "{{ RABBITMQ_USER | default('stackored') }}"
      RABBITMQ_DEFAULT_PASS: "{{ RABBITMQ_PASSWORD | default('stackored') }}"
      RABBITMQ_DEFAULT_VHOST: "{{ RABBITMQ_VHOST | default('/') }}"

    volumes:
      - stackored-rabbitmq-data:/var/lib/rabbitmq
      - stackored-rabbitmq-logs:/var/log/rabbitmq

    ports:
      - "{{ HOST_PORT_RABBITMQ | default('5672') }}:5672"
      - "{{ HOST_PORT_RABBITMQ_MGMT | default('15672') }}:15672"

    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}

volumes:
  stackored-rabbitmq-data:
  stackored-rabbitmq-logs:
