###################################################################
# STACKORED MEILISEARCH COMPOSE TEMPLATE
###################################################################

services:
  meilisearch:
    image: "getmeili/meilisearch:{{ MEILISEARCH_VERSION }}"
    container_name: "stackored-meilisearch"
    restart: unless-stopped

    environment:
      MEILI_MASTER_KEY: "{{ MEILISEARCH_MASTER_KEY | default('stackored-master-key') }}"
      MEILI_ENV: "development"
      MEILI_NO_ANALYTICS: "true"

    ports:
      - "{{ HOST_PORT_MEILISEARCH | default('7700') }}:7700"

    volumes:
      - stackored-meili-data:/meili_data

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

volumes:
  stackored-meili-data:
