#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

dbt deps                                   # dbt_packages must ship with the project

BUILD=$(mktemp -d)
trap 'rm -rf "$BUILD"' EXIT                # cleans up even if a step fails

rsync -a --exclude .git --exclude .venv --exclude .env --exclude '.env.*' \
  --exclude .user.yml --exclude /target --exclude /logs \
  --exclude .DS_Store --exclude deploy.sh ./ "$BUILD/"

snow dbt deploy MARKET_ANALYTICS_SNOW_DBT_DEPLOY \
  --source "$BUILD" \
  --database DBT_MASTERY_LAB --schema OPS \
  --default-target prod