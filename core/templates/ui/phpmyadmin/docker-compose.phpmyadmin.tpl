###################################################################
# STACKORED PHPMYADMIN COMPOSE TEMPLATE
###################################################################

services:
  phpmyadmin:
    image: "phpmyadmin/phpmyadmin:{{ PHPMYADMIN_VERSION }}"
    container_name: "stackored-phpmyadmin"
    restart: unless-stopped

    environment:
      PMA_HOST: "{{ PHPMYADMIN_HOST | default('mysql') }}"
      PMA_USER: "{{ PHPMYADMIN_USER | default('root') }}"
      PMA_PASSWORD: "{{ PHPMYADMIN_PASSWORD | default('stackored') }}"
      UPLOAD_LIMIT: "64M"

    ports:
      - "{{ HOST_PORT_PHPMYADMIN | default('8081') }}:80"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"
