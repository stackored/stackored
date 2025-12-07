###################################################################
# STACKORED SENTRY COMPOSE TEMPLATE
###################################################################

services:
  sentry:
    image: "getsentry/sentry:{{ SENTRY_VERSION }}"
    container_name: "stackored-sentry"
    restart: unless-stopped

    environment:
      SENTRY_SECRET_KEY: "{{ SENTRY_SECRET_KEY | default('stackored-sentry-secret') }}"
      SENTRY_SINGLE_ORGANIZATION: "true"

    ports:
      - "{{ HOST_PORT_SENTRY | default('9001') }}:9000"

    depends_on:
      - sentry-redis
      - sentry-postgres

    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}

  sentry-redis:
    image: redis:7
    container_name: "stackored-sentry-redis"
    restart: unless-stopped
    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}

  sentry-postgres:
    image: postgres:15
    container_name: "stackored-sentry-postgres"
    restart: unless-stopped
    environment:
      POSTGRES_DB: sentry
      POSTGRES_USER: sentry
      POSTGRES_PASSWORD: "{{ SENTRY_DB_PASSWORD | default('sentry') }}"
    volumes:
      - stackored-sentry-postgres-data:/var/lib/postgresql/data
    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}

volumes:
  stackored-sentry-postgres-data:
