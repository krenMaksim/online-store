#!/usr/bin/env bash
set -Eeuo pipefail

# ====== CONFIG ======
BRANCH="main"

# Path to this repo on the server
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# What to deploy:
# - for most simple sites use REPO_DIR
# - if your real site is inside dist/ or public/, change it
SOURCE_DIR="$REPO_DIR"

# ISPmanager site directory:
# change this to your real domain path
TARGET_DIR="/var/www/YOUR_USER/data/www/YOUR_DOMAIN"

EXCLUDE_FILE="$REPO_DIR/.deployignore"
# ====================

if [[ "$TARGET_DIR" == "/var/www/YOUR_USER/data/www/YOUR_DOMAIN" ]]; then
  echo "ERROR: edit deploy.sh and set TARGET_DIR first."
  exit 1
fi

if [[ ! -f "$EXCLUDE_FILE" ]]; then
  echo "ERROR: .deployignore not found: $EXCLUDE_FILE"
  exit 1
fi

echo "==> Repo dir:    $REPO_DIR"
echo "==> Source dir:  $SOURCE_DIR"
echo "==> Target dir:  $TARGET_DIR"
echo "==> Branch:      $BRANCH"

cd "$REPO_DIR"

echo "==> Updating repository"
git fetch origin "$BRANCH"
git checkout -f "$BRANCH"
git reset --hard "origin/$BRANCH"

mkdir -p "$TARGET_DIR"

echo "==> Deploying files"
rsync -av --delete \
  --exclude-from="$EXCLUDE_FILE" \
  "$SOURCE_DIR"/ "$TARGET_DIR"/

echo "==> Done"