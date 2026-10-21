#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
BUILD=$(mktemp -d)
rsync -a --exclude .git --exclude .venv --exclude .env --exclude '.env.*' \
  --exclude .user.yml --exclude target --exclude logs --exclude dbt_packages \
  --exclude .DS_Store --exclude deploy.sh ./ "$BUILD/"
snow stage copy "$BUILD" @DBT_MASTERY_LAB.OPS.dbt_src/ --recursive --overwrite
rm -rf "$BUILD"