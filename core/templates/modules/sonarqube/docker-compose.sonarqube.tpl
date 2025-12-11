###################################################################
# STACKORED SONARQUBE COMPOSE TEMPLATE
###################################################################

services:
  sonarqube:
    image: "sonarqube:{{ SONARQUBE_VERSION }}"
    container_name: "stackored-sonarqube"
    restart: unless-stopped

    environment:
      SONAR_ES_BOOTSTRAP_CHECKS_DISABLE: "true"
      SONAR_SEARCH_JAVAADDITIONALOPTS: "-Dnode.store.allow_mmap=false"
      SONAR_WEB_JAVAOPTS: "{{ SONARQUBE_JAVA_OPTS | default('-Xms512m -Xmx512m') }}"
      SONARQUBE_JDBC_URL: "{{ SONARQUBE_JDBC_URL | default('jdbc:postgresql://postgres/sonarqube') }}"
      SONARQUBE_JDBC_USERNAME: "{{ SONARQUBE_DB_USERNAME | default('sonar') }}"
      SONARQUBE_JDBC_PASSWORD: "{{ SONARQUBE_DB_PASSWORD | default('sonar') }}"

    ports:
      - "{{ HOST_PORT_SONARQUBE | default('9000') }}:9000"

    volumes:
      - stackored-sonarqube-data:/opt/sonarqube/data
      - stackored-sonarqube-extensions:/opt/sonarqube/extensions
      - ./logs/sonarqube:/opt/sonarqube/logs

    networks:
      - "{{ DOCKER_DEFAULT_NETWORK }}"

volumes:
  stackored-sonarqube-data:
  stackored-sonarqube-extensions:
