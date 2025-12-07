###################################################################
# STACKORED NODE.JS COMPOSE TEMPLATE
###################################################################

services:
  node:
    image: "node:{{ NODE_VERSION }}"
    container_name: "stackored-node"
    restart: unless-stopped

    working_dir: /app

    volumes:
      - ./:/app
      - stackored-node-modules:/app/node_modules

    ports:
      - "{{ HOST_PORT_NODE | default('3000') }}:3000"

    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}

    command: ["node", "--version"]

    environment:
      NODE_ENV: "{{ NODE_ENV | default('development') }}"

volumes:
  stackored-node-modules:
