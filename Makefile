build:
	docker compose build

release:
	docker compose push upnp-service

start:
	docker compose up -d

stop:
	docker compose down