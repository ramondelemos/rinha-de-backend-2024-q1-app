.PHONY: down
down:
	docker-compose -f docker-compose.yml down -v --remove-orphans

.PHONY: up
up: down
	docker-compose -f docker-compose.yml up -d
