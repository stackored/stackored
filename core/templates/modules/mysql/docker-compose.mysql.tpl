###################################################################
# STACKORED MYSQL / MARIADB / PERCONA COMPOSE TEMPLATE
###################################################################

services:
  mysql:
    image: "mysql:{{ MYSQL_VERSION }}"
    container_name: "stackored-mysql"
    restart: unless-stopped

    environment:
      MYSQL_ROOT_PASSWORD: "{{ MYSQL_ROOT_PASSWORD | default('root') }}"
      MYSQL_DATABASE: "{{ MYSQL_DATABASE | default('stackored') }}"
      MYSQL_USER: "{{ MYSQL_USER | default('stackored') }}"
      MYSQL_PASSWORD: "{{ MYSQL_PASSWORD | default('stackored') }}"

    volumes:
      - stackored-mysql-data:/var/lib/mysql
      - ./core/generated-configs/mysql.cnf:/etc/mysql/conf.d/stackored.cnf:ro
      - ./logs/mysql:/var/log/mysql

    command: >
      mysqld
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_unicode_ci
      --skip-character-set-client-handshake

ports:
- "{{ HOST_PORT_MYSQL | default('3306') }}:3306"

networks:
- "{{ DOCKER_DEFAULT_NETWORK }}"

volumes:
  stackored-mysql-data:
