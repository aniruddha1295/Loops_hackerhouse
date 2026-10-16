#!/usr/bin/env bash
# Boots the whole demo in one container:
#   fresh Postgres (schema + demo data) → PostgREST → backend → nginx on $PORT
# The database lives in /tmp, so every restart starts from clean demo data.
set -euo pipefail

export PORT="${PORT:-8080}"
export PGDATA=/tmp/pgdata
export PGHOST=/tmp
export PGUSER=postgres
export PGDATABASE=postgres

echo "[start] creating demo database"
rm -rf "$PGDATA"
initdb -D "$PGDATA" -U postgres --auth=trust --no-locale -E UTF8 >/dev/null

# Socket-only, small-memory Postgres; durability is pointless for throwaway demo data
postgres -D "$PGDATA" -k /tmp -c listen_addresses='' \
  -c shared_buffers=32MB -c max_connections=40 \
  -c fsync=off -c synchronous_commit=off -c full_page_writes=off &

until pg_isready -q; do sleep 0.2; done

for sql in /app/db/*.sql; do
  echo "[start] loading $(basename "$sql")"
  psql -q -v ON_ERROR_STOP=1 -f "$sql" >/dev/null
done

echo "[start] starting PostgREST"
PGRST_DB_URI="postgres://authenticator@/postgres?host=/tmp" \
PGRST_DB_SCHEMAS=public \
PGRST_DB_ANON_ROLE=anon \
PGRST_SERVER_HOST=127.0.0.1 \
PGRST_SERVER_PORT=3000 \
  postgrest &

echo "[start] starting backend"
(
  cd /app/backend
  SUPABASE_URL="http://127.0.0.1:${PORT}" \
  SUPABASE_ANON_KEY=local \
  SUPABASE_SERVICE_ROLE_KEY=local \
  FRONTEND_URL="${PUBLIC_URL:-http://localhost:${PORT}}" \
  NODE_ENV=production \
  PORT=3005 \
    exec node dist/server.js
) &

echo "[start] starting nginx on port ${PORT}"
envsubst '${PORT}' < /app/nginx.conf.template > /tmp/nginx.conf
nginx -e stderr -c /tmp/nginx.conf -g 'daemon off;' &

# If any process dies, exit so the host restarts the container
wait -n
echo "[start] a process exited — shutting down"
exit 1
