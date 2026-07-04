@echo off
REM =====================================================================
REM 📦 Mobile Portfolio Build Script (Android APK for Windows Hosts)
REM Author: Hermes (DevOps & Infrastructure Agent)
REM =====================================================================

echo 🚀 Starting Portfolio Build for Language Learning & IELTS AI Assistant...
cd /d "%~dp0"

echo 🧹 1. Cleaning previous build artifacts...
call flutter clean

echo 📦 2. Getting Flutter packages & dependencies...
call flutter pub get

echo 📱 3. Building Android Release APK (Split per ABI for optimized size)...
call flutter build apk --release --split-per-abi

if not exist "..\releases" mkdir "..\releases"
if exist "build\app\outputs\flutter-apk\*.apk" (
    copy /Y "build\app\outputs\flutter-apk\*.apk" "..\releases\" >nul
    echo 📦 Copied Android APK(s) to \releases directory.
)

echo.
echo 🎉 Build Completed! Portfolio demo binaries are ready in the '\releases' directory.
echo 👉 You can install the APK on an Android device or emulator using: adb install releases\app-arm64-v8a-release.apk
pause
