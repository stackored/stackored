###################################################################
# STACKORED SELENIUM CHROME COMPOSE TEMPLATE
###################################################################

services:
  selenium:
    image: "selenium/standalone-chrome:{{ SELENIUM_VERSION }}"
    container_name: "stackored-selenium"
    restart: unless-stopped

    shm_size: "{{ SELENIUM_SHM_SIZE | default('2g') }}"

    ports:
      - "{{ HOST_PORT_SELENIUM | default('4444') }}:4444"
      - "{{ HOST_PORT_SELENIUM_VNC | default('7900') }}:7900"

    environment:
      SCREEN_WIDTH: "{{ SELENIUM_SCREEN_WIDTH | default('1920') }}"
      SCREEN_HEIGHT: "{{ SELENIUM_SCREEN_HEIGHT | default('1080') }}"
      SCREEN_DEPTH: "{{ SELENIUM_SCREEN_DEPTH | default('24') }}"

    volumes:
      - ./logs/selenium:/var/log/selenium

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"
