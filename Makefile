.PHONY: up down restart logs build-tools

# Start the environment (Generate config + Docker Up)
up:
	php cli/stackored-generate
	docker-compose -f stackored.yml -f docker-compose.dynamic.yml up -d --remove-orphans

# Stop the environment
down:
	docker-compose -f stackored.yml -f docker-compose.dynamic.yml down

# Alias for down
stop: down

# Restart the environment
restart: down up

# View logs (follow)
logs:
	docker-compose -f stackored.yml -f docker-compose.dynamic.yml logs -f

# Rebuild and update the Unified Tools container
build-tools:
	docker-compose -f stackored.yml -f docker-compose.dynamic.yml up -d --build --remove-orphans stackored-tools
