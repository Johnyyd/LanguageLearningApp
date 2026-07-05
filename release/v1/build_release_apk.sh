#!/bin/bash
# Script tự động đóng gói APK release và sao chép về thư mục release/v1/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOBILE_DIR="$SCRIPT_DIR/../../mobile"
OUTPUT_APK="$SCRIPT_DIR/LanguageLearningApp-v1.apk"

echo "============================================================"
echo "📦 ĐANG CHUẨN BỊ ĐÓNG GÓI APK CHO THIẾT BỊ ANDROID THẬT"
echo "============================================================"

cd "$MOBILE_DIR"

echo "🔍 Đang kiểm tra cấu hình URL trong AppConstants..."
tailscale_url=$(grep -oP 'tailscaleFunnelUrl = "\K[^"]+' lib/core/constants/app_constants.dart || true)

if [ -n "$tailscale_url" ]; then
    echo "🌐 Tự động nhận diện Tailscale Funnel URL trong code: $tailscale_url"
else
    echo "⚠️ Chưa điền tailscaleFunnelUrl trong app_constants.dart"
    if [ -z "$1" ]; then
        echo "💡 Gợi ý: Bạn có thể truyền URL trực tiếp khi chạy script này:"
        echo "   ./build_release_apk.sh https://ai-gateway.your-tailnet.ts.net"
        echo "⏳ Đang tiếp tục build APK với cấu hình mặc định trong code..."
    else
        echo "🌐 Sử dụng URL từ tham số dòng lệnh: $1"
        DART_DEFINE_FLAG="--dart-define=API_URL=$1"
    fi
fi

if [ ! -d "android" ]; then
    echo "⚙️ Đang khởi tạo thư mục Android Gradle (flutter create --platforms=android .)..."
    flutter create --platforms=android .
fi

echo "📦 Đang tải các thư viện Flutter (flutter pub get)..."
flutter pub get

echo "🔨 Đang đóng gói APK Release (flutter build apk --release)..."
if [ -n "$DART_DEFINE_FLAG" ]; then
    flutter build apk --release $DART_DEFINE_FLAG
else
    flutter build apk --release
fi

echo "📋 Đang sao chép file APK sang thư mục release/v1/..."
cp build/app/outputs/flutter-apk/app-release.apk "$OUTPUT_APK"

echo "============================================================"
echo "🎉 ĐÃ ĐÓNG GÓI THÀNH CÔNG!"
echo "📁 File APK sẵn sàng để cài đặt trên Android thật tại:"
echo "   $OUTPUT_APK"
echo "============================================================"
