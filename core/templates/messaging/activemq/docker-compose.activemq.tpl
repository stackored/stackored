###################################################################
# STACKORED ACTIVEMQ CLASSIC COMPOSE TEMPLATE
###################################################################

services:
  activemq:
    image: "apache/activemq-classic:{{ ACTIVEMQ_VERSION }}"
    container_name: "stackored-activemq"
    restart: unless-stopped

    environment:
      ACTIVEMQ_ADMIN_LOGIN: "{{ ACTIVEMQ_ADMIN_USER }}"
      ACTIVEMQ_ADMIN_PASSWORD: "{{ ACTIVEMQ_ADMIN_PASSWORD }}"

    ports:
      - "{{ HOST_PORT_ACTIVEMQ_OPENWIRE | default('61616') }}:61616"
      - "{{ HOST_PORT_ACTIVEMQ_AMQP | default('5672') }}:5672"
      - "{{ HOST_PORT_ACTIVEMQ_STOMP | default('61613') }}:61613"
      - "{{ HOST_PORT_ACTIVEMQ_MQTT | default('1883') }}:1883"
      - "{{ HOST_PORT_ACTIVEMQ_WS | default('61614') }}:61614"
      - "{{ HOST_PORT_ACTIVEMQ_UI | default('8161') }}:8161"

    volumes:
      - stackored-activemq-data:/opt/apache-activemq/data
      - stackored-activemq-conf:/opt/apache-activemq/conf

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

volumes:
  stackored-activemq-data:
  stackored-activemq-conf:
