#!/usr/bin/env bash
# =====================================================================
# 📦 Mobile Portfolio Build Script (Android APK & iOS Bundle)
# Author: Hermes (DevOps & Infrastructure Agent)
# =====================================================================

set -e

echo "🚀 Starting Portfolio Build for Language Learning & IELTS AI Assistant..."

# Navigate to mobile directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🧹 1. Cleaning previous build artifacts..."
flutter clean

echo "📦 2. Getting Flutter packages & dependencies..."
flutter pub get

echo "📱 3. Building Android Release APK (Split per ABI for optimized size)..."
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64,android-x64

echo "🍎 4. Building iOS Release Bundle (No codesign for demo simulator/distribution)..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    flutter build ios --release --no-codesign
    echo "✅ iOS Release build completed successfully."
else
    echo "ℹ️ Skipping iOS native build (Not running on macOS host)."
fi

# Create distribution directory
mkdir -p ../releases
if [ -d "build/app/outputs/flutter-apk" ]; then
    cp build/app/outputs/flutter-apk/*.apk ../releases/ 2>/dev/null || true
    echo "📦 Copied Android APK(s) to /releases directory."
fi

echo ""
echo "🎉 Build Completed! Portfolio demo binaries are ready in the '/releases' directory."
echo "👉 You can install the APK on an Android device or emulator using: adb install releases/app-arm64-v8a-release.apk"
