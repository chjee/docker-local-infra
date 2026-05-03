# docker-local-infra

Shared local infrastructure for application repositories that run in Docker.

This repository uses `.env` as the local standard because Docker Compose loads it automatically.
`.env.example` is committed, and `.env` stays local-only.
For a public repository, `.env.example` uses placeholder secrets only.

## Contract

- Infra services run in this repository.
- Application repositories attach to the external Docker network `infra_default`.
- Applications connect to infra by container hostname, not `localhost`.
- The default container hostnames and network name are the app-facing API. If you override them in `.env`, update each application repository to match.
- DB creation and user creation happen in `initdb/mysql/01_create_databases.sh` (MySQL) and `initdb/mongo/02_mongo_init.js` (MongoDB).
- Schema creation stays in each application repository migration flow.

## Services

| Service | Hostname | Default exposed port |
| --- | --- | --- |
| MySQL | `local-mysql` | `3306` |
| Redis | `local-redis` | `6379` |
| RabbitMQ | `local-rabbitmq` | `5672`, `15672` |
| Redpanda | `local-redpanda` | `9092` (Kafka), `9644` (Admin) |
| MongoDB | `local-mongodb` | `27017` |

## Files

- `docker-compose.yml`: shared infra services
- `Makefile`: common startup and teardown commands
- `.env.example`: infra environment variables
- `initdb/mysql/01_create_databases.sh`: MySQL database and user bootstrap
- `initdb/mongo/02_mongo_init.js`: MongoDB database and user bootstrap

## Bootstrapped databases

### MySQL
- `blog_db` with shared development user `devuser`
- `hr_db` with shared development user `devuser`

### MongoDB
- `blog` with shared development user `devuser`

MongoDB uses the same shared development user and password variables as MySQL:
`DEV_DB_USER` and `DEV_DB_PASSWORD`.

## Quick start

1. Copy the env file.
2. Start the required services.
3. Start application repositories after infra is healthy.

```bash
cp .env.example .env
make up-mysql
```

To run everything:

```bash
make up-full
```

## Start and stop

Run static and Compose configuration checks:

```bash
make check
```

Start MySQL only:

```bash
make up-mysql
```

Start Redis only:

```bash
make up-redis
```

Start RabbitMQ only:

```bash
make up-rabbitmq
```

Start MySQL and Redis:

```bash
make up-mysql-redis
```

Start MySQL and RabbitMQ:

```bash
make up-mysql-rabbitmq
```

Start Redpanda only:

```bash
make up-redpanda
```

Start MongoDB only:

```bash
make up-mongodb
```

Start Redpanda and MongoDB:

```bash
make up-redpanda-mongodb
```

Start all shared infra services:

```bash
make up-full
```

Stop MySQL only:

```bash
make stop-mysql
```

Stop Redis only:

```bash
make stop-redis
```

Stop RabbitMQ only:

```bash
make stop-rabbitmq
```

Stop MySQL and Redis:

```bash
make stop-mysql-redis
```

Stop MySQL and RabbitMQ:

```bash
make stop-mysql-rabbitmq
```

Stop Redpanda only:

```bash
make stop-redpanda
```

Stop MongoDB only:

```bash
make stop-mongodb
```

Stop Redpanda and MongoDB:

```bash
make stop-redpanda-mongodb
```

Stop all running infra containers without removing them:

```bash
make stop-full
```

Stop containers and keep data (all services):

```bash
make down-full
```

Stop all containers including unnamed ones and keep data:

```bash
make down
```

Stop containers and delete volumes:

```bash
make down-clean
```

Use `make down-clean` only when you intentionally want to delete local data and re-bootstrap from scratch.

## Portability and overrides

The default service names and network name are stable for application repositories:

```env
MYSQL_CONTAINER_NAME=local-mysql
REDIS_CONTAINER_NAME=local-redis
RABBITMQ_CONTAINER_NAME=local-rabbitmq
REDPANDA_CONTAINER_NAME=local-redpanda
MONGO_CONTAINER_NAME=local-mongodb
INFRA_NETWORK_NAME=infra_default
```

If another machine already uses one of the default host ports, override only the host-side port in `.env`:

```env
MYSQL_PORT=13306
REDIS_PORT=16379
RABBITMQ_PORT=15673
RABBITMQ_MANAGEMENT_PORT=25672
REDPANDA_KAFKA_PORT=19092
REDPANDA_ADMIN_PORT=19644
MONGO_PORT=37017
```

Application containers still connect to the container port through the Docker network, for example `local-mysql:3306`.

Redpanda defaults to advertising the configured Docker hostname for application containers:

```env
REDPANDA_CONTAINER_NAME=local-redpanda
# Effective default: PLAINTEXT://${REDPANDA_CONTAINER_NAME}:9092
```

For host-machine Kafka clients that connect through the published port, override it locally:

```env
REDPANDA_ADVERTISE_KAFKA_ADDR=PLAINTEXT://localhost:9092
```

## Volumes and bootstrap

MySQL and MongoDB init scripts run only when their data directory is empty.
Changing `.env` later does not automatically update users, passwords, or databases stored in existing named volumes.

Use one of these paths:

- Fresh local data: run `make down-clean` only when you intentionally want to delete all local infra volumes and re-bootstrap.
- Existing local data: apply a manual migration or re-run a targeted bootstrap command against the running container.

MongoDB previously used a hardcoded app password in `initdb/mongo/02_mongo_init.js`.
New fresh volumes use `DEV_DB_PASSWORD` from `.env`; existing `mongodb_data` volumes keep their old user credentials until migrated or reset.

## Add a new project database

1. Add new DB/user variables to `.env.example` and your local `.env`.
2. Extend `initdb/mysql/01_create_databases.sh` with the new bootstrap block.
3. Re-apply the bootstrap script to the running MySQL container.
4. Update the target application repository environment variables.
5. Run that repository's migrations.

```bash
set -a
. ./.env
set +a
docker cp .env "${MYSQL_CONTAINER_NAME:-local-mysql}:/tmp/infra.env"
docker exec "${MYSQL_CONTAINER_NAME:-local-mysql}" sh -c 'set -a; . /tmp/infra.env; set +a; exec /docker-entrypoint-initdb.d/01_create_databases.sh'
docker exec "${MYSQL_CONTAINER_NAME:-local-mysql}" rm -f /tmp/infra.env
```

## Local env file

Start from:

```bash
cp .env.example .env
```

Current bootstrap variables:

```env
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=root
MYSQL_BUFFER_POOL_SIZE=256M
MYSQL_CONTAINER_NAME=local-mysql

REDIS_PORT=6379
REDIS_MAXMEMORY=256mb
REDIS_CONTAINER_NAME=local-redis

RABBITMQ_PORT=5672
RABBITMQ_MANAGEMENT_PORT=15672
RABBITMQ_USER=admin
RABBITMQ_PASSWORD=admin
RABBITMQ_MEMORY_WATERMARK=0.2
RABBITMQ_CONTAINER_NAME=local-rabbitmq

REDPANDA_KAFKA_PORT=9092
REDPANDA_ADMIN_PORT=9644
REDPANDA_MEMORY=512M
REDPANDA_CONTAINER_NAME=local-redpanda

MONGO_PORT=27017
MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=admin
MONGO_CACHE_SIZE=0.25
MONGO_CONTAINER_NAME=local-mongodb
MONGO_APP_DB=blog

INFRA_NETWORK_NAME=infra_default

BLOG_DB_NAME=blog_db
HR_DB_NAME=hr_db

DEV_DB_USER=devuser
DEV_DB_PASSWORD=changeme
```

`MYSQL_ROOT_PASSWORD` and `MONGO_ROOT_PASSWORD` are used for container bootstrap.
Replace placeholder values in your local `.env` before starting the stack.
Application repositories must use DB credentials that match this local `.env`.

## Example application network config

```yaml
services:
  app:
    networks:
      - infra_default

networks:
  infra_default:
    external: true
    name: infra_default
```

## Example application database URL

```env
DATABASE_URL=mysql://devuser:changeme@local-mysql:3306/blog_db
```
