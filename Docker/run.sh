#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# Load env file so compose and checks use the same credentials
if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi

# Ensure Data directory exists for the volume mount
mkdir -p Data

echo "Starting PostgreSQL with Docker Compose..."
docker compose --env-file .env up -d

echo "Waiting for PostgreSQL to be ready..."
docker compose exec postgres pg_isready -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" || true

echo "PostgreSQL is running. Connection: localhost:5432"
