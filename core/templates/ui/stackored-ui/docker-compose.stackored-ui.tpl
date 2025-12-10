###################################################################
# STACKORED WEB UI COMPOSE TEMPLATE
# Nginx container for serving the web interface
###################################################################

services:
  stackored-ui:
    image: "nginx:alpine"
    container_name: "stackored-ui"
    restart: unless-stopped
    
    volumes:
      - ./.ui:/usr/share/nginx/html:ro
    
    networks:
      - {{ DOCKER_DEFAULT_NETWORK }}
    
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.stackored-ui.rule=Host(`stackored.loc`)"
      - "traefik.http.routers.stackored-ui.entrypoints=websecure"
      - "traefik.http.routers.stackored-ui.tls=true"
      - "traefik.http.services.stackored-ui.loadbalancer.server.port=80"
