###################################################################
# STACKORED NGROK COMPOSE TEMPLATE
###################################################################

services:
  ngrok:
    image: "ngrok/ngrok:{{ NGROK_VERSION }}"
    container_name: "stackored-ngrok"
    restart: unless-stopped

    environment:
      NGROK_AUTHTOKEN: "{{ NGROK_AUTHTOKEN }}"
      NGROK_ADDR: "{{ NGROK_ADDR | default('nginx:80') }}"
      NGROK_DOMAIN: "{{ NGROK_DOMAIN | default('') }}"
      NGROK_PROTOCOL: "{{ NGROK_PROTOCOL | default('http') }}"

    command:
      - "{{ NGROK_PROTOCOL | default('http') }}"
      - "{{ NGROK_ADDR | default('nginx:80') }}"

    ports:
      - "{{ HOST_PORT_NGROK | default('4040') }}:4040"

    volumes:
      - ./logs/ngrok:/var/log/ngrok

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"
