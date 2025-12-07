###################################################################
# STACKORED PERCONA COMPOSE TEMPLATE
###################################################################

services:
  percona:
    image: "percona:{{ PERCONA_VERSION }}"
    container_name: "stackored-percona"
    platform: linux/amd64
    restart: unless-stopped
    
    environment:
      MYSQL_ROOT_PASSWORD: "{{ PERCONA_ROOT_PASSWORD | default('root') }}"
      MYSQL_DATABASE: "{{ PERCONA_DATABASE | default('stackored') }}"
      MYSQL_USER: "{{ PERCONA_USER | default('stackored') }}"
      MYSQL_PASSWORD: "{{ PERCONA_PASSWORD | default('stackored') }}"

    volumes:
      - stackored-percona-data:/var/lib/mysql
      - ./core/templates/database/percona/my.cnf:/etc/mysql/conf.d/stackored.cnf:ro

    ports:
      - "{{ HOST_PORT_PERCONA | default('3307') }}:3306"

    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}

volumes:
  stackored-percona-data:
