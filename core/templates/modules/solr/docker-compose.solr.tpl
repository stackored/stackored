###################################################################
# STACKORED APACHE SOLR COMPOSE TEMPLATE
###################################################################

services:
  solr:
    image: "solr:{{ SOLR_VERSION }}"
    container_name: "stackored-solr"
    restart: unless-stopped

    environment:
      # Solr ana dizini
      SOLR_HOME: /var/solr
      # JVM Memory ayarları
      SOLR_JAVA_MEM: "{{ SOLR_JAVA_MEM | default('-Xms512m -Xmx512m') }}"
      # Analytics kapatma
      SOLR_OPTS: >-
        {{ SOLR_OPTS | default('-Dsolr.disable.shardsyslog=true -Dsolr.jetty.inetaccess.allowall=true') }}

    command:
      - solr-precreate
      - "{{ SOLR_DEFAULT_CORE | default('stackored-core') }}"

    volumes:
      # Solr data directory
      - stackored-solr-data:/var/solr
      # Varsayılan veya override solr configsets
      - ./stackored-config/solr/configsets:/opt/solr/server/solr/configsets

    ports:
      - "{{ HOST_PORT_SOLR | default('8983') }}:8983"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

volumes:
  stackored-solr-data:
