#!/usr/bin/env bash
# Runs the SQL tests against a throwaway database on a plain local Postgres
# (no Docker / Supabase stack needed). Uses the standard PG* env variables.
#   PGHOST=/tmp PGPORT=5432 PGUSER=postgres tool/sql_tests/run.sh
set -euo pipefail
cd "$(dirname "$0")/../.."

DB=detox_sql_tests
PSQL=(psql -v ON_ERROR_STOP=1 -q -X)
export PGOPTIONS="${PGOPTIONS:-} -c client_min_messages=warning"

"${PSQL[@]}" -d postgres -c "drop database if exists $DB" -c "create database $DB"
"${PSQL[@]}" -d "$DB" -f tool/sql_tests/stub_supabase.sql
for migration in supabase/migrations/*.sql; do
  "${PSQL[@]}" -d "$DB" -f "$migration"
done
for test in tool/sql_tests/*_test.sql; do
  echo "== $test"
  "${PSQL[@]}" -d "$DB" -f "$test"
done
echo "All SQL tests passed."
