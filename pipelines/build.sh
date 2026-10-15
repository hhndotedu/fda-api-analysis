#!/usr/bin/env bash
set -euo pipefail

if [[ -z "$FDA_DATABASE_URL" ]]; then
  echo "Error: FDA_DATABASE_URL is not set"
  exit 1
fi

# ... fetch the base ingestion data

for f in sql/00_setup.sql sql/staging/*.sql sql/marts/*.sql; do
  echo "Running $f"
  psql "$FDA_DATABASE_URL" -v ON_ERROR_STOP=1 -f "$f"
done