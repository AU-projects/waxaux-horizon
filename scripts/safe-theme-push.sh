#!/usr/bin/env bash
# Safe wrapper around `shopify theme push` for this repo.
#
# Why this exists: the GitHub<->Shopify connection is bidirectional — every
# theme change (editor OR push) gets synced back to GitHub as an
# "Update from Shopify" commit. If you push from a stale local checkout,
# you silently overwrite whatever the merchant changed in the theme editor
# since your last pull (font/color settings, section text edits, layout
# tweaks — anything saved through the editor). This script always pulls
# first (so local has the merchant's latest edits before you touch files),
# always excludes config/settings_data.json (theme-editor-owned state we
# must never hand-edit or overwrite), and pulls again after push to absorb
# Shopify's sync-back commit.
#
# Usage: scripts/safe-theme-push.sh <store> <theme-id>
# Example: scripts/safe-theme-push.sh vinilivenali.myshopify.com 204267454796

set -euo pipefail

STORE="${1:?Usage: $0 <store> <theme-id>}"
THEME_ID="${2:?Usage: $0 <store> <theme-id>}"

echo "==> Pulling latest (catches any theme-editor edits since last sync)"
git pull origin main --no-edit

echo "==> Running shopify theme check"
shopify theme check

echo "==> Pushing to $STORE theme $THEME_ID (settings_data.json excluded)"
shopify theme push --store "$STORE" --theme="$THEME_ID" --ignore="config/settings_data.json"

echo "==> Pulling again to absorb Shopify's sync-back commit"
git pull origin main --no-edit

echo "==> Pushing to origin/main"
git push origin main

echo "Done."
