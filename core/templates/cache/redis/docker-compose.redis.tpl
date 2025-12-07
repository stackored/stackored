###################################################################
# STACKORED REDIS COMPOSE TEMPLATE
###################################################################

services:
  redis:
    image: "redis:{{ REDIS_VERSION }}"
    container_name: "stackored-redis"
    restart: unless-stopped

    command: ["redis-server", "/etc/redis/redis.conf"]

    volumes:
      - stackored-redis-data:/data
      - ./stackored/core/templates/cache/redis/redis.conf:/etc/redis/redis.conf:ro

    ports:
      - "{{ HOST_PORT_REDIS | default('6379') }}:6379"

    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}

volumes:
  stackored-redis-data:
