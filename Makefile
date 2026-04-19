up-mysql:
	docker compose --profile mysql up -d

up-redis:
	docker compose --profile redis up -d

up-rabbitmq:
	docker compose --profile rabbitmq up -d

up-mysql-redis:
	docker compose --profile mysql --profile redis up -d

up-mysql-rabbitmq:
	docker compose --profile mysql --profile rabbitmq up -d

up-redpanda:
	docker compose --profile redpanda up -d

up-mongodb:
	docker compose --profile mongodb up -d

up-redpanda-mongodb:
	docker compose --profile redpanda --profile mongodb up -d

up-full:
	docker compose --profile full up -d

stop-mysql:
	docker compose stop mysql

stop-redis:
	docker compose stop redis

stop-rabbitmq:
	docker compose stop rabbitmq

stop-redpanda:
	docker compose stop redpanda

stop-mongodb:
	docker compose stop mongodb

stop-mysql-redis:
	docker compose stop mysql redis

stop-mysql-rabbitmq:
	docker compose stop mysql rabbitmq

stop-redpanda-mongodb:
	docker compose stop redpanda mongodb

down-redpanda:
	docker compose down redpanda

down-mongodb:
	docker compose down mongodb

down-redpanda-mongodb:
	docker compose down redpanda mongodb

stop-full:
	docker compose stop mysql redis rabbitmq redpanda mongodb

down-full:
	docker compose down mysql redis rabbitmq redpanda mongodb

down:
	docker compose down

down-clean:
	docker compose down -v
