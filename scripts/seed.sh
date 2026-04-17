#!/usr/bin/env bash
set -euo pipefail
docker compose run --rm mapproxy mapproxy-seed -f /app/mapproxy.yaml -s /app/seed.yaml --concurrency 2
