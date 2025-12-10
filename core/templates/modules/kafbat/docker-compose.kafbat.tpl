###################################################################
# STACKORED KAFBAT UI COMPOSE TEMPLATE
###################################################################

services:
  kafbat-ui:
    image: "ghcr.io/kafbat/kafka-ui:{{ KAFBAT_VERSION }}"
    container_name: "stackored-kafbat"
    restart: unless-stopped

    environment:
      DYNAMIC_CONFIG_ENABLED: "true"
      KAFKA_CLUSTERS_0_NAME: "{{ KAFBAT_CLUSTER_NAME | default('stackored-kafka') }}"
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: "{{ KAFBAT_KAFKA_BOOTSTRAP | default('stackored-kafka:9092') }}"

    ports:
      - "{{ HOST_PORT_KAFBAT | default('8080') }}:8080"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"
