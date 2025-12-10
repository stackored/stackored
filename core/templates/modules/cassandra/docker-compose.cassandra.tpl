###################################################################
# STACKORED CASSANDRA COMPOSE TEMPLATE
###################################################################

services:
  cassandra:
    image: "cassandra:{{ CASSANDRA_VERSION }}"
    container_name: "stackored-cassandra"
    restart: unless-stopped

    environment:
      CASSANDRA_CLUSTER_NAME: "{{ CASSANDRA_CLUSTER_NAME | default('StackoredCluster') }}"
      CASSANDRA_DC: "{{ CASSANDRA_DC | default('dc1') }}"
      CASSANDRA_RACK: "{{ CASSANDRA_RACK | default('rack1') }}"
      CASSANDRA_ENDPOINT_SNITCH: "{{ CASSANDRA_ENDPOINT_SNITCH | default('GossipingPropertyFileSnitch') }}"
      MAX_HEAP_SIZE: "{{ CASSANDRA_MAX_HEAP_SIZE | default('512M') }}"
      HEAP_NEWSIZE: "{{ CASSANDRA_HEAP_NEWSIZE | default('128M') }}"

    volumes:
      - stackored-cassandra-data:/var/lib/cassandra

    ports:
      - "{{ HOST_PORT_CASSANDRA | default('9042') }}:9042"
      - "{{ HOST_PORT_CASSANDRA_JMX | default('7199') }}:7199"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

    healthcheck:
      test: ["CMD-SHELL", "cqlsh -e 'describe cluster'"]
      interval: 30s
      timeout: 10s
      retries: 5

volumes:
  stackored-cassandra-data:
