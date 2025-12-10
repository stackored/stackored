###################################################################
# STACKORED ELASTICSEARCH COMPOSE TEMPLATE
###################################################################

services:
  elasticsearch:
    image: "docker.elastic.co/elasticsearch/elasticsearch:{{ ELASTICSEARCH_VERSION }}"
    container_name: "stackored-elasticsearch"
    restart: unless-stopped

    environment:
      - discovery.type=single-node
      - ES_JAVA_OPTS={{ ES_JAVA_OPTS | default('-Xms1g -Xmx1g') }}
      - xpack.security.enabled={{ ELASTIC_SECURITY | default('false') }}
      - xpack.security.enrollment.enabled={{ ELASTIC_ENROLLMENT | default('false') }}
      - cluster.name=stackored-es
      - network.host=0.0.0.0

    ulimits:
      memlock: -1
      nofile: 65536

    volumes:
      - stackored-elasticsearch-data:/usr/share/elasticsearch/data

    ports:
      - "{{ HOST_PORT_ELASTICSEARCH | default('9200') }}:9200"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

volumes:
  stackored-elasticsearch-data:
