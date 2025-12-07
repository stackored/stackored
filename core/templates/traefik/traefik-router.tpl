###################################################################
# TRAEFIK ROUTER TEMPLATE
###################################################################

labels:
- "traefik.enable=true"

# Router
- "traefik.http.routers.{{ PROJECT_SLUG }}.entrypoints=websecure"
- "traefik.http.routers.{{ PROJECT_SLUG }}.rule=Host(`{{ PROJECT_DOMAIN }}`)"
- "traefik.http.routers.{{ PROJECT_SLUG }}.service={{ PROJECT_SLUG }}-svc"

{% if TRAEFIK_USE_GLOBAL_REDIRECT_TO_HTTPS == "true" %}
- "traefik.http.routers.{{ PROJECT_SLUG }}.middlewares={{ PROJECT_SLUG }}-redir"
{% endif %}

# TLS (only if https enabled)
{% if TRAEFIK_ENABLE_LETSENCRYPT == "true" %}
- "traefik.http.routers.{{ PROJECT_SLUG }}.tls.certresolver=letsencrypt"
{% else %}
- "traefik.http.routers.{{ PROJECT_SLUG }}.tls=true"
{% endif %}
