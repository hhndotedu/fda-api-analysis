#!/usr/bin/env bash
set -euo pipefail

for f in sql/00_setup.sql sql/staging/*.sql sql/marts/*.sql; do
  echo "Running $f"
  psql "$FDA_DATABASE_URL" -v ON_ERROR_STOP=1 -f "$f"
done