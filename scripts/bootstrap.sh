#!/usr/bin/env bash
set -e

echo "Bootstrapping Acadyk Monorepo..."
cd "$(dirname "$0")/../apps/mobile"

if command -v flutter &> /dev/null; then
  flutter pub get
else
  echo "Flutter is not installed in PATH. Please run 'flutter pub get' inside apps/mobile/."
fi

echo "Acadyk Monorepo Bootstrap Complete!"
