#!/usr/bin/env bash
set -euo pipefail

flutter pub get

# Apply formatting to the repository.
dart format .

# Confirm that formatting is now clean.
dart format --output=none --set-exit-if-changed .

# Run the same checks as GitHub Actions.
flutter analyze
flutter test

echo "Flutter validation passed."
