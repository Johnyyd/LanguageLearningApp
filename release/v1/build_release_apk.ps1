# Script tự động đóng gói APK release và sao chép về thư mục release/v1/ trên Windows 11 (PowerShell)
# Cách chạy: .\build_release_apk.ps1 [Tùy chọn: https://ai-gateway.your-tailnet.ts.net]

$ErrorActionPreference = "Stop"

$ScriptDir = $PSScriptRoot
$MobileDir = Resolve-Path (Join-Path $ScriptDir "..\..\mobile")
$OutputApk = Join-Path $ScriptDir "LanguageLearningApp-v1.apk"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "📦 ĐANG CHUẨN BỊ ĐÓNG GÓI APK CHO THIẾT BỊ ANDROID THẬT" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Set-Location $MobileDir

Write-Host "🔍 Đang kiểm tra cấu hình URL trong AppConstants..." -ForegroundColor Yellow
$appConstantsPath = Join-Path $MobileDir "lib\core\constants\app_constants.dart"
$tailscaleUrl = ""

if (Test-Path $appConstantsPath) {
    $content = Get-Content $appConstantsPath -Raw
    if ($content -match 'tailscaleFunnelUrl\s*=\s*"([^"]+)"') {
        $tailscaleUrl = $Matches[1]
    }
}

$DartDefineFlag = ""

if ($tailscaleUrl -and $tailscaleUrl -ne "") {
    Write-Host "🌐 Tự động nhận diện Tailscale Funnel URL trong code: $tailscaleUrl" -ForegroundColor Green
} else {
    Write-Host "⚠️ Chưa điền tailscaleFunnelUrl trong app_constants.dart" -ForegroundColor Yellow
    if ($args.Count -eq 0) {
        Write-Host "💡 Gợi ý: Bạn có thể truyền URL trực tiếp khi chạy script này trên PowerShell:" -ForegroundColor Magenta
        Write-Host "   .\build_release_apk.ps1 https://ai-gateway.taild6d848.ts.net" -ForegroundColor Magenta
        Write-Host "⏳ Đang tiếp tục build APK với cấu hình mặc định trong code..." -ForegroundColor Yellow
    } else {
        $customUrl = $args[0]
        Write-Host "🌐 Sử dụng URL từ tham số dòng lệnh: $customUrl" -ForegroundColor Green
        $DartDefineFlag = "--dart-define=API_URL=$customUrl"
    }
}

$androidDir = Join-Path $MobileDir "android"
if (!(Test-Path $androidDir)) {
    Write-Host "⚙️ Đang khởi tạo thư mục Android Gradle (flutter create --platforms=android .)..." -ForegroundColor Yellow
    flutter create --platforms=android .
}

Write-Host "📦 Đang tải các thư viện Flutter (flutter pub get)..." -ForegroundColor Yellow
flutter pub get

Write-Host "🔍 Kiểm tra và patch tự động cho flutter_unity_widget trong Pub Cache..." -ForegroundColor Yellow
& "$PSScriptRoot\patch_pub_cache.ps1"

Write-Host "🔨 Đang đóng gói APK Release (flutter build apk --release)..." -ForegroundColor Cyan
if ($DartDefineFlag -ne "") {
    flutter build apk --release $DartDefineFlag
} else {
    flutter build apk --release
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Đóng gói APK thất bại! Vui lòng kiểm tra lỗi bên trên." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "📋 Đang sao chép file APK sang thư mục release/v1/..." -ForegroundColor Yellow
$builtApkPath = Join-Path $MobileDir "build\app\outputs\flutter-apk\app-release.apk"

if (Test-Path $builtApkPath) {
    Copy-Item -Path $builtApkPath -Destination $OutputApk -Force
    Write-Host "============================================================" -ForegroundColor Green
    Write-Host "🎉 ĐÃ ĐÓNG GÓI THÀNH CÔNG!" -ForegroundColor Green
    Write-Host "📁 File APK sẵn sàng để cài đặt trên Android thật tại:" -ForegroundColor Green
    Write-Host "   $OutputApk" -ForegroundColor Yellow
    Write-Host "============================================================" -ForegroundColor Green
} else {
    Write-Host "❌ Không tìm thấy file APK sau khi build tại $builtApkPath" -ForegroundColor Red
    exit 1
}
