###################################################################
# STACKORED POSTGRES COMPOSE TEMPLATE
###################################################################

services:
  postgres:
    image: "postgres:{{ POSTGRES_VERSION }}"
    container_name: "stackored-postgres"
    restart: unless-stopped

    environment:
      POSTGRES_DB: "{{ POSTGRES_DB | default('stackored') }}"
      POSTGRES_USER: "{{ POSTGRES_USER | default('stackored') }}"
      POSTGRES_PASSWORD: "{{ POSTGRES_PASSWORD | default('stackored') }}"
      PGDATA: "/var/lib/postgresql/data/pgdata"

    volumes:
      - stackored-postgres-data:/var/lib/postgresql/data/pgdata
      - ./logs/postgres:/var/log/postgresql

    ports:
      - "{{ HOST_PORT_POSTGRES | default('5432') }}:5432"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

volumes:
  stackored-postgres-data:
