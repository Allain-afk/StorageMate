#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  format)
    flutter format .
    ;;
  analyze)
    flutter analyze
    ;;
  test)
    flutter test
    ;;
  test-goldens)
    flutter test --update-goldens
    ;;
  build-debug)
    flutter build apk --debug
    ;;
  *)
    echo "Usage: $0 {format|analyze|test|test-goldens|build-debug}"
    exit 1
    ;;
 esac
