#!/usr/bin/env bash
set -euo pipefail
docker compose up --build -d mapproxy
echo "MapProxy started: http://localhost:8091/demo/"
