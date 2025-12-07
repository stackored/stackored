###################################################################
# STACKORED MARIADB COMPOSE TEMPLATE
###################################################################

services:
  mariadb:
    image: "mariadb:{{ MARIADB_VERSION }}"
    container_name: "stackored-mariadb"
    restart: unless-stopped

    environment:
      MARIADB_ROOT_PASSWORD: "{{ MARIADB_ROOT_PASSWORD | default('root') }}"
      MARIADB_DATABASE: "{{ MARIADB_DATABASE | default('stackored') }}"
      MARIADB_USER: "{{ MARIADB_USER | default('stackored') }}"
      MARIADB_PASSWORD: "{{ MARIADB_PASSWORD | default('stackored') }}"

    volumes:
      - stackored-mariadb-data:/var/lib/mysql
      - ./core/templates/database/mariadb/my.cnf:/etc/mysql/conf.d/stackored.cnf:ro

    command: >
      mariadbd
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_unicode_ci

    ports:
      - "{{ HOST_PORT_MARIADB | default('3307') }}:3306"

    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}

volumes:
  stackored-mariadb-data:
