#!/bin/sh
set -eu

read_required_var() {
  var_name="$1"
  eval "var_value=\${$var_name:-}"
  if [ -z "$var_value" ]; then
    echo "Missing required environment variable: $var_name" >&2
    exit 1
  fi
  printf "%s" "$var_value"
}

sql_escape_string() {
  printf "%s" "$1" | sed "s/'/''/g"
}

sql_escape_ident() {
  printf "%s" "$1" | sed "s/\`/\`\`/g"
}

mysql_root_password="$(read_required_var MYSQL_ROOT_PASSWORD)"
blog_db_raw="$(read_required_var BLOG_DB_NAME)"
hr_db_raw="$(read_required_var HR_DB_NAME)"
dev_db_user_raw="$(read_required_var DEV_DB_USER)"
dev_db_password_raw="$(read_required_var DEV_DB_PASSWORD)"

blog_db_name="$(sql_escape_ident "$blog_db_raw")"
hr_db_name="$(sql_escape_ident "$hr_db_raw")"
dev_db_user="$(sql_escape_string "$dev_db_user_raw")"
dev_db_password="$(sql_escape_string "$dev_db_password_raw")"

mysql -uroot -p"${mysql_root_password}" <<SQL
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
