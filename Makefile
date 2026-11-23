.PHONY: help dev up down clean test test-api test-packages run-api run-emulator run-local

JAVA_HOME ?= /home/shankar/.sdkman/candidates/java/21.0.7-oracle

help:
	@echo "EngineBeats Development Commands:"
	@echo "  make run-local    Run local emulator with dummy logs and telemetry streaming"
	@echo "  make dev          Start local containers (Postgres, Keycloak, Caddy, Emulator)"
	@echo "  make down         Stop all local containers"
	@echo "  make test-api     Run Spring Boot API unit & integration tests"
	@echo "  make run-api      Run Spring Boot API locally with Maven"
	@echo "  make emulator     Run Python ELM327 Car Emulator locally"
	@echo "  make clean        Clean build artifacts and containers"

run-local:
	./run-local.sh

dev:
	docker-compose up -d postgres keycloak elm327-emulator caddy

down:
	docker-compose down -v

test-api:
	cd services/api && JAVA_HOME=$(JAVA_HOME) mvn clean test

run-api:
	cd services/api && JAVA_HOME=$(JAVA_HOME) mvn spring-boot:run -Dspring-boot.run.profiles=dev

emulator:
	python3 tools/elm327-emulator/elm327_server.py

clean:
	docker-compose down -v
	rm -rf services/api/target
	rm -rf packages/obd-core/.dart_tool packages/obd-core/build
	rm -rf apps/mobile/.dart_tool apps/mobile/build
