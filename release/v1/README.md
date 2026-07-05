# 🚀 Hướng Dẫn Cài Đặt & Đóng Gói APK Kết Nối Tailscale Funnel

Để ứng dụng Android được cài đặt trên thiết bị thật (điện thoại, máy tính bảng bên ngoài mạng local) có thể kết nối mượt mà về server AI Gateway (cổng `1112`) đang chạy trên máy này, chúng ta đã tích hợp kiến trúc **Tailscale Funnel** theo hướng dẫn từ repository [Johnyyd/tailscale_public_url](https://github.com/Johnyyd/tailscale_public_url).

---

## 🛠 Bước 1: Cấu hình Tailscale trong Docker Compose
Chúng ta đã thêm service `tunnel-ai-gateway` vào file `backend/docker-compose.yml`.

### 1.1 Lấy Auth Key từ Tailscale
1. Truy cập: [https://login.tailscale.com/admin/settings/keys](https://login.tailscale.com/admin/settings/keys)
2. Nhấn **Generate auth key...**
3. Bật tùy chọn **Reusable** và **Ephemeral** (tùy chọn), sau đó nhấn Generate.
4. Copy key (có dạng `tskey-auth-xxxxx...`).

### 1.2 Điền Auth Key vào hệ thống
Bạn có thể thiết lập biến môi trường trước khi chạy Docker, hoặc sửa trực tiếp trong `backend/docker-compose.yml`:
```yaml
environment:
  - TS_AUTHKEY=tskey-auth-xxxxxxxxxxxxxxxxx # Thay key của bạn vào đây
```

---

## 🌐 Bước 2: Khởi động Tailscale Funnel & Lấy Public URL
Trong thư mục `backend`, chạy script tự động cấu hình mà chúng tôi đã chuẩn bị:
```bash
cd backend
chmod +x setup_tailscale_funnel.sh
./setup_tailscale_funnel.sh
```

Script này sẽ tự động:
- Khởi động container `tunnel-ai-gateway`
- Cài đặt `tailscale serve` và bật `tailscale funnel --bg http://127.0.0.1:1112`
- Hiển thị **Public URL** (ví dụ: `https://ai-gateway.your-tailnet-name.ts.net`)

---

## 📱 Bước 3: Cấu hình URL cho Ứng dụng Mobile & Đóng gói APK
Bạn có **2 cách** để trỏ ứng dụng về Public URL vừa tạo:

### Cách 1: Điền trực tiếp vào Code (Khuyên dùng)
Mở file `mobile/lib/core/constants/app_constants.dart` và dán URL vào biến `tailscaleFunnelUrl`:
```dart
class AppConstants {
    // Dán URL từ bước 2 vào đây:
    static const String tailscaleFunnelUrl = "https://ai-gateway.your-tailnet.ts.net";
    ...
}
```

### Cách 2: Truyền URL qua dòng lệnh khi build
Không cần sửa code, bạn chỉ cần truyền URL vào tham số khi chạy script đóng gói:
```bash
cd release/v1
chmod +x build_release_apk.sh
./build_release_apk.sh https://ai-gateway.your-tailnet.ts.net
```

---

## 📦 Bước 4: Đóng gói APK Release
Chạy lệnh đóng gói trong thư mục `release/v1`:
```bash
cd release/v1
chmod +x build_release_apk.sh
./build_release_apk.sh
```
*(Lưu ý: Script sẽ tự động gọi `flutter build apk --release` và copy file APK hoàn thiện ra `release/v1/LanguageLearningApp-v1.apk`).*

---

## ✨ Kiểm tra trên Thiết bị Android Thật
1. Copy file `release/v1/LanguageLearningApp-v1.apk` vào điện thoại Android thật và cài đặt.
2. Mở ứng dụng (đảm bảo điện thoại có kết nối 4G/5G hoặc Wi-Fi bất kỳ).
3. Ứng dụng sẽ gọi API trực tiếp qua HTTPS Public URL từ Tailscale Funnel về máy tính server của bạn với tốc độ cao và bảo mật tuyệt đối!
