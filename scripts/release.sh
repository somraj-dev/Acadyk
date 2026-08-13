#!/usr/bin/env bash
set -e

echo "Preparing Release Build..."
cd "$(dirname "$0")/../apps/mobile"

if command -v flutter &> /dev/null; then
  flutter build apk --release
else
  echo "Flutter is not installed in PATH. Please run 'flutter build apk --release' inside apps/mobile/."
fi
