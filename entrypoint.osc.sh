#!/bin/bash
set -e

# Parse DATABASE_URL if provided
# Format: postgres://user:password@host:port/database
if [ -n "$DATABASE_URL" ]; then
  # Extract protocol (database type)
  proto="$(echo $DATABASE_URL | grep :// | sed -e 's,^\(.*\)://.*,\1,g')"

  # Remove protocol
  url="$(echo $DATABASE_URL | sed -e "s,$proto://,,g")"

  # Extract user and password
  userpass="$(echo $url | grep @ | cut -d@ -f1)"
  export DB_USER="$(echo $userpass | cut -d: -f1)"
  export DB_PASS="$(echo $userpass | cut -d: -f2)"

  # Extract host and port
  hostport="$(echo $url | sed -e "s,$userpass@,,g" | cut -d/ -f1)"
  export DB_HOST="$(echo $hostport | cut -d: -f1)"
  port="$(echo $hostport | cut -d: -f2)"
  if [ -n "$port" ] && [ "$port" != "$DB_HOST" ]; then
    export DB_PORT="$port"
  fi

  # Extract database name
  export DB_NAME="$(echo $url | grep / | cut -d/ -f2 | cut -d? -f1)"

  # Set database type
  case "$proto" in
    postgres|postgresql)
      export DB_TYPE="postgres"
      ;;
    mysql)
      export DB_TYPE="mysql"
      ;;
    *)
      export DB_TYPE="$proto"
      ;;
  esac

  echo "Parsed DATABASE_URL: type=$DB_TYPE host=$DB_HOST port=$DB_PORT db=$DB_NAME user=$DB_USER"
fi

exec "$@"
