###################################################################
# STACKORED RUBY ENVIRONMENT COMPOSE TEMPLATE
###################################################################

services:
ruby:
image: "ruby:{{ RUBY_VERSION }}"
container_name: "stackored-ruby"
restart: unless-stopped

working_dir: /app

volumes:
- ./projects/{{ PROJECT_NAME }}/:/app

environment:
BUNDLE_PATH: "/gems"

command: "{{ RUBY_COMMAND | default('tail -f /dev/null') }}"

networks:
- {{ DOCKER_DEFAULT_NETWORK }}
