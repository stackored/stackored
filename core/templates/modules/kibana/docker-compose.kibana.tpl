###################################################################
# STACKORED KIBANA COMPOSE TEMPLATE
###################################################################

services:
  kibana:
    image: "kibana:{{ KIBANA_VERSION }}"
    container_name: "stackored-kibana"
    restart: unless-stopped

    environment:
      ELASTICSEARCH_HOSTS: "{{ KIBANA_ELASTICSEARCH_HOSTS | default('http://stackored-elasticsearch:9200') }}"
      SERVER_NAME: "{{ KIBANA_SERVER_NAME | default('stackored-kibana') }}"
      SERVER_HOST: "{{ KIBANA_SERVER_HOST | default('0.0.0.0') }}"

    volumes:
      - stackored-kibana-data:/usr/share/kibana/data
      - ./logs/kibana:/usr/share/kibana/logs

    ports:
      - "{{ HOST_PORT_KIBANA | default('5601') }}:5601"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

    depends_on:
      - elasticsearch

    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:5601/api/status || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5

volumes:
  stackored-kibana-data:
