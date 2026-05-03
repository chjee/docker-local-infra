.PHONY: \
	check \
	check-config \
	check-overrides \
	check-redpanda-advertise-default \
	check-scripts \
	up-mysql \
	up-redis \
	up-rabbitmq \
	up-mysql-redis \
	up-mysql-rabbitmq \
	up-redpanda \
	up-mongodb \
	up-redpanda-mongodb \
	up-full \
	stop-mysql \
	stop-redis \
	stop-rabbitmq \
	stop-redpanda \
	stop-mongodb \
	stop-mysql-redis \
	stop-mysql-rabbitmq \
	stop-redpanda-mongodb \
	down-redpanda \
	down-mongodb \
	down-redpanda-mongodb \
	stop-full \
	down-full \
	down \
	down-clean

check: check-config check-overrides check-redpanda-advertise-default check-scripts

check-config:
	docker compose --env-file .env.example --profile full config >/dev/null

check-overrides:
	env MYSQL_PORT=13306 REDIS_PORT=16379 RABBITMQ_PORT=15673 RABBITMQ_MANAGEMENT_PORT=25672 REDPANDA_KAFKA_PORT=19092 REDPANDA_ADMIN_PORT=19644 MONGO_PORT=37017 MYSQL_CONTAINER_NAME=portable-mysql REDIS_CONTAINER_NAME=portable-redis RABBITMQ_CONTAINER_NAME=portable-rabbitmq REDPANDA_CONTAINER_NAME=portable-redpanda MONGO_CONTAINER_NAME=portable-mongodb INFRA_NETWORK_NAME=portable_infra docker compose --env-file .env.example --profile full config >/dev/null

check-redpanda-advertise-default:
	env REDPANDA_CONTAINER_NAME=portable-redpanda docker compose --env-file .env.example --profile redpanda config | grep -q 'PLAINTEXT://portable-redpanda:9092'

check-scripts:
	node --check initdb/mongo/02_mongo_init.js
	bash -n initdb/mysql/01_create_databases.sh
	shellcheck initdb/mysql/01_create_databases.sh

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
