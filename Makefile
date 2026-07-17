SHELL := /bin/bash
COMPOSE_FILE ?= docker-compose.yml

.PHONY: build up down logs ps

build:
	@if docker compose version >/dev/null 2>&1; then \
		echo "Trying: docker compose build"; \
		if docker compose -f $(COMPOSE_FILE) build; then \
			exit 0; \
		fi; \
		echo "docker compose build failed, trying docker-compose build fallback"; \
	fi; \
	docker-compose -f $(COMPOSE_FILE) build

up:
	@if docker compose version >/dev/null 2>&1; then \
		echo "Trying: docker compose up -d"; \
		if docker compose -f $(COMPOSE_FILE) up -d; then \
			exit 0; \
		fi; \
		echo "docker compose up failed, trying docker-compose up -d fallback"; \
	fi; \
	docker-compose -f $(COMPOSE_FILE) up -d

down:
	@if docker compose version >/dev/null 2>&1; then \
		echo "Trying: docker compose down"; \
		if docker compose -f $(COMPOSE_FILE) down; then \
			exit 0; \
		fi; \
		echo "docker compose down failed, trying docker-compose down fallback"; \
	fi; \
	docker-compose -f $(COMPOSE_FILE) down

logs:
	@if docker compose version >/dev/null 2>&1; then \
		docker compose -f $(COMPOSE_FILE) logs -f awg-client squid dante; \
	else \
		docker-compose -f $(COMPOSE_FILE) logs -f awg-client squid dante; \
	fi

ps:
	@if docker compose version >/dev/null 2>&1; then \
		docker compose -f $(COMPOSE_FILE) ps; \
	else \
		docker-compose -f $(COMPOSE_FILE) ps; \
	fi
