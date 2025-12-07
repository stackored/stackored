###################################################################
# STACKORED COUCHDB COMPOSE TEMPLATE
###################################################################

services:
  couchdb:
    image: "couchdb:{{ COUCHDB_VERSION }}"
    container_name: "stackored-couchdb"
    restart: unless-stopped

    environment:
      COUCHDB_USER: "{{ COUCHDB_USER | default('admin') }}"
      COUCHDB_PASSWORD: "{{ COUCHDB_PASSWORD | default('stackored') }}"

    volumes:
      - stackored-couchdb-data:/opt/couchdb/data
      - stackored-couchdb-config:/opt/couchdb/etc/local.d

    ports:
      - "{{ HOST_PORT_COUCHDB | default('5984') }}:5984"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5984/_up"]
      interval: 30s
      timeout: 10s
      retries: 5

volumes:
  stackored-couchdb-data:
  stackored-couchdb-config:
