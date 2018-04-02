SHELL=bash
.PHONY: network db api

NETWORK_NAME=pgt-network

DB_TAG=pgt-db-tag
DB_WORKDIR=/var/workdir/db
DB_NAME=pgt-postgres-name

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

db:
	-docker rm -f $(DB_NAME)

	docker build -t $(DB_TAG) \
		--build-arg DB_WORKDIR=$(DB_WORKDIR) \
		db/.

	docker run -p $(POSTGRES_PORT):$(POSTGRES_PORT) -it \
		--volume $(shell pwd)/db:$(DB_WORKDIR):ro \
		--network=$(NETWORK_NAME) \
		--network-alias=$(POSTGRES_HOST) \
		-e POSTGRES_USER=$(POSTGRES_USER) \
		-e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		-e POSTGRES_HOST=$(POSTGRES_HOST) \
		-e POSTGRES_PORT=$(POSTGRES_PORT) \
		-e POSTGRES_DB=$(POSTGRES_DB) \
		--name $(DB_NAME) \
		$(DB_TAG)

seed:
	-docker exec -it $(DB_NAME) \
		/bin/bash $(DB_WORKDIR)/load.sh schema-drop.sql

	docker exec -it $(DB_NAME) \
		/bin/bash $(DB_WORKDIR)/load.sh schema.sql

	docker exec -it $(DB_NAME) \
		/bin/bash $(DB_WORKDIR)/load.sh data.sql

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
