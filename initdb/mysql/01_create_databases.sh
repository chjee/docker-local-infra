#!/bin/sh
set -eu

require_var() {
  var_name="$1"
  eval "var_value=\${$var_name:-}"
  if [ -z "$var_value" ]; then
    echo "Missing required environment variable: $var_name" >&2
    exit 1
  fi
}

sql_escape_string() {
  printf "%s" "$1" | sed "s/'/''/g"
}

sql_escape_ident() {
  printf "%s" "$1" | sed 's/`/``/g'
}

require_var MYSQL_ROOT_PASSWORD
require_var BLOG_DB_NAME
require_var HR_DB_NAME
require_var DEV_DB_USER
require_var DEV_DB_PASSWORD

blog_db_name="$(sql_escape_ident "$BLOG_DB_NAME")"
hr_db_name="$(sql_escape_ident "$HR_DB_NAME")"
dev_db_user="$(sql_escape_string "$DEV_DB_USER")"
dev_db_password="$(sql_escape_string "$DEV_DB_PASSWORD")"

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE DATABASE IF NOT EXISTS \`${blog_db_name}\`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

CREATE DATABASE IF NOT EXISTS \`${hr_db_name}\`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

CREATE USER IF NOT EXISTS '${dev_db_user}'@'%' IDENTIFIED BY '${dev_db_password}';
GRANT ALL PRIVILEGES ON \`${blog_db_name}\`.* TO '${dev_db_user}'@'%';
GRANT ALL PRIVILEGES ON \`${hr_db_name}\`.* TO '${dev_db_user}'@'%';

FLUSH PRIVILEGES;
SQL
