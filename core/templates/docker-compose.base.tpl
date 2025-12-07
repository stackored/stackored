version: "3.9"

###################################################################
# STACKORED BASE COMPOSE (TRAefik & GLOBAL NETWORK)
###################################################################

services:

traefik:
image: traefik:latest
container_name: stackored-traefik
command:
- "--api.dashboard=true"
- "--providers.docker=true"
- "--providers.docker.exposedbydefault=false"
{% if TRAEFIK_ENABLE_LETSENCRYPT == "true" %}
- "--entrypoints.websecure.http.tls.certresolver=letsencrypt"
- "--certificatesresolvers.letsencrypt.acme.email={{ TRAEFIK_EMAIL }}"
- "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
{% endif %}
ports:
- "80:80"
- "443:443"
- "8080:8080" # Dashboard
volumes:
- /var/run/docker.sock:/var/run/docker.sock:ro
- stackored-letsencrypt:/letsencrypt
networks:
- "{{ DOCKER_DEFAULT_NETWORK }}"

networks:
{{ DOCKER_DEFAULT_NETWORK }}:
external: true

volumes:
stackored-letsencrypt:
