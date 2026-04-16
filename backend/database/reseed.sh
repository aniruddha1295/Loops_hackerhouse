#!/bin/bash
# Reseed script — drops all data and reloads seed.sql
# Usage: ./reseed.sh
# Requires: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in environment (or .env file)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Reseeding Database ==="
echo "WARNING: This will DELETE all existing data and reload seed data."
read -p "Are you sure? (y/N) " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborted."
  exit 0
fi

# Load .env if present
if [ -f "$SCRIPT_DIR/../.env" ]; then
  export $(grep -v '^#' "$SCRIPT_DIR/../.env" | xargs)
fi

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
  echo "ERROR: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set"
  exit 1
fi

# Use Supabase REST API to truncate tables (reverse FK order)
# Note: For full SQL execution, use the Supabase SQL Editor in the dashboard
# This script is a helper — paste the SQL below into Supabase SQL Editor

echo ""
echo "Run the following SQL in Supabase SQL Editor (Settings > SQL Editor):"
echo "=================================================================="
echo ""
cat <<'SQL'
-- Step 1: Delete all data (reverse FK order)
DELETE FROM scheduled_callbacks;
DELETE FROM escalations;
DELETE FROM call_tool_executions;
DELETE FROM call_logs;
DELETE FROM claims;
DELETE FROM policies;
DELETE FROM customers;

SQL

echo ""
echo "Then run seed.sql:"
echo "=================================================================="
cat "$SCRIPT_DIR/seed.sql"
echo ""
echo "=== Done ==="
