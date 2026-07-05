#!/bin/bash
# Hướng dẫn từ repo: https://github.com/Johnyyd/tailscale_public_url
# Script tự động kích hoạt Tailscale Funnel cho AI Gateway (cổng 1112)

echo "⏳ Đang kiểm tra và khởi động container tunnel-ai-gateway..."
docker compose up -d tunnel-ai-gateway

echo "⏳ Đang chờ Tailscale Bootstrap..."
sleep 5

# Bước 6 trong repo: Tạo Public URL cho Tunnel
echo "🌐 Đang tạo cấu hình Tailscale Funnel cho cổng 1112 (AI Gateway)..."
docker exec tunnel-ai-gateway tailscale serve reset
docker exec tunnel-ai-gateway tailscale funnel --bg http://localhost:1112

echo ""
echo "============================================================"
echo "✅ ĐÃ CẤU HÌNH TAILSCALE FUNNEL THÀNH CÔNG!"
echo "============================================================"
echo "📍 Public URL của server hiện tại là:"
docker exec tunnel-ai-gateway tailscale funnel status

echo ""
echo "👉 Hướng dẫn tiếp theo cho ứng dụng Android thật:"
echo "1. Copy URL https://... ở trên (ví dụ: https://ai-gateway.your-tailnet.ts.net)"
echo "2. Dán vào biến tailscaleFunnelUrl trong file:"
echo "   mobile/lib/core/constants/app_constants.dart"
echo "3. Chạy lệnh đóng gói APK trong thư mục release/v1/: ./build_release_apk.sh"
echo "============================================================"
