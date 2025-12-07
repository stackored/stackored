###################################################################
# STACKORED RUST ENVIRONMENT COMPOSE TEMPLATE
###################################################################

services:
rust:
image: "rust:{{ RUST_VERSION }}"
container_name: "stackored-rust"
restart: unless-stopped

working_dir: /app

volumes:
- ./projects/{{ PROJECT_NAME }}/:/app

environment:
CARGO_HOME: /cargo

command: "{{ RUST_COMMAND | default('tail -f /dev/null') }}"

networks:
- {{ DOCKER_DEFAULT_NETWORK }}
