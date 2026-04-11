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

up-full:
	docker compose --profile full up -d

stop-mysql:
	docker compose stop mysql

stop-redis:
	docker compose stop redis

stop-rabbitmq:
	docker compose stop rabbitmq

stop-mysql-redis:
	docker compose stop mysql redis

stop-mysql-rabbitmq:
	docker compose stop mysql rabbitmq

stop-full:
	docker compose stop mysql redis rabbitmq

down:
	docker compose down

down-clean:
	docker compose down -v
