###################################################################
# STACKORED PYTHON ENVIRONMENT COMPOSE TEMPLATE
###################################################################

services:
python:
image: "python:{{ PYTHON_VERSION }}"
container_name: "stackored-python"
restart: unless-stopped

working_dir: /app

volumes:
- ./projects/{{ PROJECT_NAME }}/:/app

command: "{{ PYTHON_COMMAND | default('tail -f /dev/null') }}"

networks:
- {{ DOCKER_DEFAULT_NETWORK }}
