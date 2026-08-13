#!/usr/bin/env bash
set -e

echo "Running Unit & Widget Tests..."
cd "$(dirname "$0")/../apps/mobile"

if command -v flutter &> /dev/null; then
  flutter test
else
  echo "Flutter is not installed in PATH. Please run 'flutter test' inside apps/mobile/."
fi
