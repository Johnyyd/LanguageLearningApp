@echo off
REM Script tu dong dong goi APK release tren Windows 11 (Command Prompt / Double-click)
REM Ban co the chay: build_release_apk.bat [https://ai-gateway.your-tailnet.ts.net]

setlocal
set SCRIPT_DIR=%~dp0
set MOBILE_DIR=%SCRIPT_DIR%..\..\mobile

echo ============================================================
echo [INFO] DANG CHUAN BI DONG GOI APK CHO THIET BI ANDROID THAT
echo ============================================================

cd /d "%MOBILE_DIR%"

if exist "android" goto skip_android_init
echo [INFO] Dang khoi tao thu muc Android Gradle: flutter create --platforms=android .
call flutter create --platforms=android .
:skip_android_init

echo [INFO] Dang tai cac thu vien Flutter: flutter pub get ...
call flutter pub get

echo [INFO] Kiem tra va patch tu dong cho flutter_unity_widget trong Pub Cache...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_pub_cache.ps1"

echo [INFO] Dang dong goi APK Release: flutter build apk --release ...
if "%~1"=="" goto default_build
echo [INFO] Su dung URL tu tham so dong lenh: %~1
call flutter build apk --release --dart-define=API_URL=%~1
goto build_done

:default_build
echo [INFO] Su dung URL mac dinh trong app_constants.dart: https://ai-gateway.taild6d848.ts.net
call flutter build apk --release

:build_done
if errorlevel 1 (
    echo [ERROR] Dong goi APK that bai! Vui long kiem tra loi ben tren.
    pause
    exit /b %errorlevel%
)

echo [INFO] Dang sao chep file APK sang thu muc release\v1\ ...
copy /y "build\app\outputs\flutter-apk\app-release.apk" "%SCRIPT_DIR%LanguageLearningApp-v1.apk"

echo ============================================================
echo [SUCCESS] DA DONG GOI THANH CONG!
echo [INFO] File APK san sang de cai dat tren Android that tai:
echo        %SCRIPT_DIR%LanguageLearningApp-v1.apk
echo ============================================================
if "%COMSPEC%" neq "" pause
endlocal
