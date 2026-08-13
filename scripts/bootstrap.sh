#!/usr/bin/env bash
set -e
echo "Bootstrapping Acadyk monorepo..."
cd apps/mobile && flutter pub get
