#!/usr/bin/env bash
set -e
echo "Preparing release build..."
cd apps/mobile && flutter build apk --release
