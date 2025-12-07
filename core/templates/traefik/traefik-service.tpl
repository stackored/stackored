###################################################################
# TRAEFIK SERVICE TEMPLATE
###################################################################

labels:
- "traefik.http.services.{{ PROJECT_SLUG }}-svc.loadbalancer.server.port={{ PROJECT_INTERNAL_PORT | default('9000') }}"
- "traefik.http.services.{{ PROJECT_SLUG }}-svc.loadbalancer.passhostheader=true"
