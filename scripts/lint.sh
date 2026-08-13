#!/usr/bin/env bash
set -e
echo "Analyzing codebase..."
cd apps/mobile && flutter analyze
