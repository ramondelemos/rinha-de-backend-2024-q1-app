.PHONY: down
down:
	docker-compose -f docker-compose.yml down -v --remove-orphans

.PHONY: up
up: down
	docker-compose -f docker-compose.yml up -d

.PHONY: docker-image
docker-image:
	docker image build \
		--pull \
		--tag ramondelemos/rinha_backend:latest \
		-f Dockerfile \
		.

.PHONY: deploy-docker-hub
deploy-docker-hub: docker-image
	docker login -u "$(DOCKER_USER)" -p "$(DOCKER_PASS)"
	docker push ramondelemos/rinha_backend:latest
