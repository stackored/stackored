.PHONY: help up down restart logs ps build-tools generate

COMPOSE_FILES = -f stackored.yml -f docker-compose.dynamic.yml -f docker-compose.projects.yml

help:
	@echo "Stackored Makefile Commands:"
	@echo "  make up          - Start all services"
	@echo "  make down        - Stop all services"
	@echo "  make restart     - Restart all services"
	@echo "  make logs        - View logs (all services)"
	@echo "  make ps          - List running containers"
	@echo "  make build-tools - Rebuild tools container"
	@echo "  make generate    - Run stackored-generate"

up:
	docker-compose $(COMPOSE_FILES) up -d

down:
	docker-compose $(COMPOSE_FILES) down

restart:
	docker-compose $(COMPOSE_FILES) restart

logs:
	docker-compose $(COMPOSE_FILES) logs -f

ps:
	docker-compose $(COMPOSE_FILES) ps

build-tools:
	docker-compose $(COMPOSE_FILES) up -d --build tools

generate:
	docker run --rm -v "$$(pwd):/app" -w /app php:8.2-cli php cli/stackored-generate--remove-orphans stackored-tools
