###################################################################
# STACKORED MONGO COMPOSE TEMPLATE
###################################################################

services:
  mongo:
    image: "mongo:{{ MONGO_VERSION }}"
    container_name: "stackored-mongo"
    restart: unless-stopped

    environment:
      MONGO_INITDB_ROOT_USERNAME: "{{ MONGO_USER | default('root') }}"
      MONGO_INITDB_ROOT_PASSWORD: "{{ MONGO_PASSWORD | default('root') }}"
      MONGO_INITDB_DATABASE: "{{ MONGO_DATABASE | default('stackored') }}"

    volumes:
      - stackored-mongo-data:/data/db
      - ./stackored/core/templates/database/mongo/mongo.conf:/etc/mongo/mongo.conf:ro

    ports:
      - "{{ HOST_PORT_MONGO | default('27017') }}:27017"

    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}

volumes:
  stackored-mongo-data:
