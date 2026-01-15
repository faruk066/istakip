#!/bin/bash

echo "Flutter Web Build Script for Vercel"

# Install Flutter
if [ -d "flutter" ]; then
    echo "Flutter directory already exists."
else
    echo "Cloning Flutter SDK..."
    git clone https://github.com/flutter/flutter.git -b stable
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Run Flutter doctor to check environment
echo "Running flutter doctor..."
flutter doctor

# Enable web support (just in case)
flutter config --enable-web

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build the web application
echo "Building web application..."
flutter build web --release

echo "Build complete."
