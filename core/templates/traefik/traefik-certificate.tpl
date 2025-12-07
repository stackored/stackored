###################################################################
# TRAEFIK CUSTOM CERTIFICATE TEMPLATE
###################################################################

labels:
- "traefik.http.routers.{{ PROJECT_SLUG }}.tls=true"
- "traefik.http.routers.{{ PROJECT_SLUG }}.tls.domains[0].main={{ PROJECT_DOMAIN }}"
- "traefik.http.routers.{{ PROJECT_SLUG }}.tls.domains[0].sans=*.{{ PROJECT_DOMAIN }}"
- "traefik.http.routers.{{ PROJECT_SLUG }}.tls.certresolver={{ TRAEFIK_ENABLE_LETSENCRYPT == 'true' ? 'letsencrypt' : 'default' }}"

volumes:
- "{{ PROJECT_CERT_PATH }}/cert.pem:/certs/cert.pem:ro"
- "{{ PROJECT_CERT_PATH }}/key.pem:/certs/key.pem:ro"
