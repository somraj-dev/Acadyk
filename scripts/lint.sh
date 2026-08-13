#!/usr/bin/env bash
set -e

echo "Analyzing Acadyk Codebase..."
cd "$(dirname "$0")/../apps/mobile"

if command -v flutter &> /dev/null; then
  flutter analyze
else
  echo "Flutter is not installed in PATH. Please run 'flutter analyze' inside apps/mobile/."
fi
