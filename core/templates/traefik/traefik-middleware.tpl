###################################################################
# TRAEFIK MIDDLEWARE TEMPLATE
###################################################################

labels:
# Redirect HTTP → HTTPS (optional)
- "traefik.http.middlewares.{{ PROJECT_SLUG }}-redir.redirectscheme.scheme=https"

# Security Headers
- "traefik.http.middlewares.{{ PROJECT_SLUG }}-headers.headers.stsSeconds=63072000"
- "traefik.http.middlewares.{{ PROJECT_SLUG }}-headers.headers.stsIncludeSubdomains=true"
- "traefik.http.middlewares.{{ PROJECT_SLUG }}-headers.headers.stsPreload=true"
- "traefik.http.middlewares.{{ PROJECT_SLUG }}-headers.headers.frameDeny=true"
- "traefik.http.middlewares.{{ PROJECT_SLUG }}-headers.headers.contentTypeNosniff=true"

# Global security middleware
- "traefik.http.routers.{{ PROJECT_SLUG }}.middlewares={{ PROJECT_SLUG }}-headers"
