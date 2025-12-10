###################################################################
# STACKORED WEB UI COMPOSE TEMPLATE
# Nginx + PHP-FPM container for serving the web interface
###################################################################

services:
  stackored-ui:
    build:
      context: ./.ui
      dockerfile: Dockerfile
    container_name: "stackored-ui"
    restart: unless-stopped
    
    volumes:
      - ./.ui:/usr/share/nginx/html:ro
      - ./:/app:ro
      - /var/run/docker.sock:/var/run/docker.sock
    
    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}
    
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.stackored-ui.rule=Host(`stackored.loc`)"
      - "traefik.http.routers.stackored-ui.entrypoints=websecure"
      - "traefik.http.routers.stackored-ui.tls=true"
      - "traefik.http.services.stackored-ui.loadbalancer.server.port=80"
