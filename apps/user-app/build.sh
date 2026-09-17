#!/bin/bash
echo "Installing Flutter..."
# Clone the Flutter repo if it doesn't exist
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi
# Add Flutter to path
export PATH="$PATH:`pwd`/flutter/bin"
# Enable web
flutter config --enable-web
# Build the app
flutter build web --release
