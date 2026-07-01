#!/bin/sh
# =============================================================================
# Xcode Cloud — ci_post_clone.sh
# Installs Flutter SDK + CocoaPods so Xcode Cloud can build the Flutter app.
# Signing & TestFlight upload are handled automatically by Xcode Cloud.
# =============================================================================
set -e

echo "=== Xcode Cloud post-clone: Flutter setup ==="

# 1. Install Flutter (stable channel, shallow clone)
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

flutter --version

# 2. Precache iOS artifacts
flutter precache --ios

# 3. Project dependencies (repo root)
cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter pub get

# 4. CocoaPods
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods
cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
pod install

echo "=== post-clone done ==="
exit 0
