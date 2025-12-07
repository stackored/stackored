###################################################################
# STACKORED TOMCAT COMPOSE TEMPLATE
###################################################################

services:
  tomcat:
    image: "tomcat:{{ TOMCAT_VERSION }}"
    container_name: "stackored-tomcat"
    restart: unless-stopped

    volumes:
      - ./core/templates/appserver/tomcat/webapps:/usr/local/tomcat/webapps
      - stackored-tomcat-logs:/usr/local/tomcat/logs

    ports:
      - "{{ HOST_PORT_TOMCAT | default('8080') }}:8080"

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

    environment:
      CATALINA_OPTS: "{{ TOMCAT_CATALINA_OPTS | default('-Xms512M -Xmx1024M') }}"
      JAVA_OPTS: "{{ TOMCAT_JAVA_OPTS | default('-Djava.awt.headless=true') }}"

volumes:
  stackored-tomcat-logs:
