# docker-local-infra

Shared local infrastructure for application repositories that run in Docker.

This repository uses `.env` as the local standard because Docker Compose loads it automatically.
`.env.example` is committed, and `.env` stays local-only.
For a public repository, `.env.example` uses placeholder secrets only.

## Contract

- Infra services run in this repository.
- Application repositories attach to the external Docker network `infra_default`.
- Applications connect to infra by container hostname, not `localhost`.
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

## Add a new project database

1. Add new DB/user variables to `.env.example` and your local `.env`.
2. Extend `initdb/01_create_databases.sh` with the new bootstrap block.
3. Re-apply the bootstrap script to the running MySQL container.
4. Update the target application repository environment variables.
5. Run that repository's migrations.

```bash
docker cp .env local-mysql:/tmp/infra.env
docker exec local-mysql sh -c 'set -a; . /tmp/infra.env; set +a; exec /docker-entrypoint-initdb.d/01_create_databases.sh'
docker exec local-mysql rm -f /tmp/infra.env
```

## Local env file

Start from:

```bash
cp .env.example .env
```

Current bootstrap variables:

```env
BLOG_DB_NAME=blog_db
HR_DB_NAME=hr_db

DEV_DB_USER=devuser
DEV_DB_PASSWORD=changeme

REDPANDA_MEMORY=512M

MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=admin
MONGO_CACHE_SIZE=0.25
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
```

## Example application database URL

```env
DATABASE_URL=mysql://devuser:changeme@local-mysql:3306/blog_db
```
