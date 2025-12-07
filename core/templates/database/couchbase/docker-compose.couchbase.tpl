###################################################################
# STACKORED COUCHBASE COMPOSE TEMPLATE
###################################################################

services:
  couchbase:
    image: "couchbase:{{ COUCHBASE_VERSION }}"
    container_name: "stackored-couchbase"
    restart: unless-stopped

    environment:
      COUCHBASE_ADMINISTRATOR_USERNAME: "{{ COUCHBASE_ADMIN_USER | default('Administrator') }}"
      COUCHBASE_ADMINISTRATOR_PASSWORD: "{{ COUCHBASE_ADMIN_PASSWORD | default('stackored') }}"

    volumes:
      - stackored-couchbase-data:/opt/couchbase/var

    ports:
      - "{{ HOST_PORT_COUCHBASE_WEB | default('8091') }}:8091"
      - "{{ HOST_PORT_COUCHBASE_API | default('8092') }}:8092"
      - "{{ HOST_PORT_COUCHBASE_INTERNAL | default('8093') }}:8093"
      - "{{ HOST_PORT_COUCHBASE_QUERY | default('8094') }}:8094"
      - "{{ HOST_PORT_COUCHBASE_FTS | default('8095') }}:8095"
      - "{{ HOST_PORT_COUCHBASE_CLIENT | default('11210') }}:11210"

    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}

volumes:
  stackored-couchbase-data:
