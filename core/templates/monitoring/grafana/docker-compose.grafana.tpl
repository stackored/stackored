###################################################################
# STACKORED GRAFANA COMPOSE TEMPLATE
###################################################################

services:
  grafana:
    image: "grafana/grafana:{{ GRAFANA_VERSION }}"
    container_name: "stackored-grafana"
    restart: unless-stopped

    environment:
      GF_SECURITY_ADMIN_USER: "{{ GRAFANA_ADMIN_USER }}"
      GF_SECURITY_ADMIN_PASSWORD: "{{ GRAFANA_ADMIN_PASSWORD }}"
      GF_INSTALL_PLUGINS: ""
      GF_SERVER_ROOT_URL: "http://grafana.stackored.{{ DEFAULT_TLD_SUFFIX | default('loc') }}"

    volumes:
      - stackored-grafana-data:/var/lib/grafana
      - stackored-grafana-config:/etc/grafana

    ports:
      - "{{ HOST_PORT_GRAFANA | default('3001') }}:3000"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

    user: "{{ HOST_USER_ID | default('472') }}"

volumes:
  stackored-grafana-data:
  stackored-grafana-config:
