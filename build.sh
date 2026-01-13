#!/bin/bash
set -e  # Exit on error

# Install Flutter
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
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
