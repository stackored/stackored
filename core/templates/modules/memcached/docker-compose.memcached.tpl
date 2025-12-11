###################################################################
# STACKORED MEMCACHED COMPOSE TEMPLATE
###################################################################

services:
  memcached:
    image: "memcached:{{ MEMCACHED_VERSION }}"
    container_name: "stackored-memcached"
    restart: unless-stopped

    command: >
      memcached
      -m {{ MEMCACHED_MEMORY | default('256') }}
      -c {{ MEMCACHED_CONNECTIONS | default('1024') }}
      -t {{ MEMCACHED_THREADS | default('4') }}
      {{ MEMCACHED_EXTRA_ARGS | default('') }}

    ports:
      - "{{ HOST_PORT_MEMCACHED | default('11211') }}:11211"

    volumes:
      - ./logs/memcached:/var/log/memcached

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"
