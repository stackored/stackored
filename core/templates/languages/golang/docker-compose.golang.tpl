###################################################################
# STACKORED GOLANG ENVIRONMENT COMPOSE TEMPLATE
###################################################################

services:
golang:
image: "golang:{{ GOLANG_VERSION }}"
container_name: "stackored-golang"
restart: unless-stopped

working_dir: /app

volumes:
- ./projects/{{ PROJECT_NAME }}/:/app

environment:
GO111MODULE: "on"
GOPATH: /go

command: "{{ GOLANG_COMMAND | default('tail -f /dev/null') }}"

networks:
- "{{ DOCKER_DEFAULT_NETWORK }}"
