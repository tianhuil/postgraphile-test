.PHONY: network postgres api

NETWORK_NAME=pgt-network

POSTGRES_NAME=pgt-postgres-name
POSTGRES_USER=postgres_user
POSTGRES_PASSWORD=password
POSTGRES_HOST=postgres-host
POSTGRES_PORT=5432
POSTGRES_DB=postgres

API_TAG=pgt-api-tag
API_NAME=pgt-api-name

API_PORT=5000

network:
	-docker network rm $(NETWORK_NAME)
	docker network create --driver bridge $(NETWORK_NAME)

postgres:
	-docker rm -f $(POSTGRES_NAME)

	docker run -p $(POSTGRES_PORT):$(POSTGRES_PORT) -it \
		--network=$(NETWORK_NAME) \
		--network-alias=$(POSTGRES_HOST) \
		-e POSTGRES_USER=$(POSTGRES_USER) \
		-e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		-e POSTGRES_DB=$(POSTGRES_DB) \
		--name $(POSTGRES_NAME) \
		onjin/alpine-postgres

api:
	-docker rm -f $(API_NAME)

	docker build -t $(API_TAG) \
	api/.

	docker run -p $(API_PORT):$(API_PORT) -it \
		--network=$(NETWORK_NAME) \
		-e API_PORT=$(API_PORT) \
		-e POSTGRES_USER=$(POSTGRES_USER) \
		-e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		-e POSTGRES_HOST=$(POSTGRES_HOST) \
		-e POSTGRES_PORT=$(POSTGRES_PORT) \
		-e POSTGRES_DB=$(POSTGRES_DB) \
		--name $(API_NAME) \
		$(API_TAG)
