###################################################################
# TRAEFIK MAIN CONFIG TEMPLATE
###################################################################

log:
level: INFO

api:
dashboard: true
insecure: false

entryPoints:
web:
address: ":80"
http:
redirections:
entryPoint:
to: websecure
scheme: https
permanent: "{{ TRAEFIK_USE_GLOBAL_REDIRECT_TO_HTTPS }}"
websecure:
address: ":443"
http:
tls:
certResolver: "{{ TRAEFIK_ENABLE_LETSENCRYPT == 'true' ? 'letsencrypt' : '' }}"

providers:
docker:
exposedByDefault: false
watch: true

{% if TRAEFIK_ENABLE_LETSENCRYPT == "true" %}
certificatesResolvers:
letsencrypt:
acme:
email: "{{ TRAEFIK_EMAIL }}"
storage: "/letsencrypt/acme.json"
httpChallenge:
entryPoint: web
{% endif %}
