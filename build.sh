#!/bin/bash
set -e  # Exit on error

# Install Flutter
echo "Installing Flutter..."
# Remove existing Flutter directory if it exists (from cache)
if [ -d "flutter" ]; then
  echo "Removing existing Flutter directory..."
  rm -rf flutter
fi

# Clone Flutter if not already available
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

export PATH="$PATH:`pwd`/flutter/bin"

# Verify Flutter installation
flutter --version

# Install dependencies
echo "Installing dependencies..."
flutter pub get

# Build web
echo "Building web app..."
flutter build web --release

echo "Build completed successfully!"
