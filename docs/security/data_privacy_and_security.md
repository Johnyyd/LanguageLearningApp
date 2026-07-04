# 🔒 Quy chuẩn Bảo mật & Quyền riêng tư Dữ liệu (Data Security & Privacy Guidelines)

Tài liệu này quy định các tiêu chuẩn bảo mật, mã hóa dữ liệu và tuân thủ quyền riêng tư bắt buộc đối với toàn bộ hệ thống **Language Learning & IELTS AI Assistant**. 

> [!CAUTION]
> **Nguyên tắc "Zero-Trust" & Privacy-First:** Mọi thông tin định danh cá nhân (PII), hình ảnh chụp bài thi viết tay, âm thanh hội thoại và các khóa bảo mật (API Keys/Tokens) phải được bảo vệ tối đa ở cả trạng thái nghỉ (Data at Rest) và trạng thái truyền tải (Data in Transit).

---

## 1. Quản lý Khóa Bảo mật & API Gateway (API Key & Gateway Security)

### 1.1. Cấm Hardcode API Key dưới Client
- **Quy tắc tuyệt đối:** Không bao giờ được phép nhúng trực tiếp hoặc gián tiếp các khóa API nhạy cảm (Google Gemini API Key, OpenAI Key, Cloud TTS Key, Supabase Secret Key) bên trong mã nguồn Flutter Client (`mobile/lib/...`), kể cả trong các file cấu hình `.env` được build cùng ứng dụng di động.
- **Mô hình Proxy qua AI Gateway:**
  ```
  [📱 Flutter Client] --(JWT Token / HTTPS)--> [🛡️ Backend AI Gateway] --(API Key / Secure VNet)--> [🌐 Gemini / TTS Cloud]
  ```
- Mọi yêu cầu xử lý AI (chấm điểm IELTS, OCR bài viết, trò chuyện 3D Tutor) phải được gửi đến Backend AI Gateway của dự án. Gateway sẽ kiểm tra quyền (JWT Auth), áp dụng giới hạn tần suất (Rate Limiter) trước khi đính kèm API Key chính thức để gọi dịch vụ Cloud AI.

### 1.2. Quản lý Biến Môi trường (Environment Variables)
- Trên Backend (NestJS/FastAPI), các khóa bảo mật phải được nạp từ biến môi trường của OS hoặc dịch vụ Secret Manager (Docker Secrets / AWS Secrets Manager / Vault).
- File `.env` chứa bí mật tuyệt đối không được commit lên hệ thống quản lý phiên bản Git (đã được cấu hình chặt chẽ trong `.gitignore`).
- Các AI Agents (`OpenCode`, `Hermes`) khi khởi tạo môi trường mới chỉ được sử dụng file mẫu `.env.example` với các giá trị giả lập (placeholder).

---

## 2. Mã hóa & Bảo mật Dữ liệu Cục bộ (Local Storage Security)

### 2.1. Quản lý Token & Credential với `flutter_secure_storage`
Để bảo vệ phiên đăng nhập và token xác thực khỏi các cuộc tấn công khai thác trên thiết bị bị đã Root/Jailbreak, tầng Client phải tuân thủ:
- **Chuẩn mã hóa:** Sử dụng thư viện `flutter_secure_storage` (áp dụng **AES-GCM** trên Android qua Keystore và **Keychain Services** trên iOS).
- **Dữ liệu bắt buộc lưu trong Secure Storage:**
  - `access_token` (JWT) và `refresh_token`.
  - Thông tin xác thực OAuth2 (Google / Apple ID credentials).
  - Mã định danh người dùng nhạy cảm (PII identifiers).
- **Dữ liệu học tập thông thường (Non-sensitive Data):**
  - Danh sách từ vựng N5, trạng thái thẻ Spaced Repetition (SRS), lịch sử điểm số có thể được lưu trong Local Database tốc độ cao (`Hive` hoặc `Isar`), nhưng không được chứa mật khẩu hoặc thông tin thanh toán.

```dart
// Ví dụ chuẩn mực khi lưu trữ và đọc Token xác thực
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _tokenKey = 'auth_access_token';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearAllSecrets() async {
    await _storage.deleteAll();
  }
}
```

---

## 3. Bảo mật Giao tiếp Mạng (Network & Transport Security)

### 3.1. Mã hóa đường truyền (Data in Transit)
- **100% HTTPS / TLS 1.3:** Toàn bộ kết nối REST API và WebSockets (WSS) giữa ứng dụng di động và máy chủ bắt buộc phải mã hóa qua chuẩn TLS 1.2 hoặc TLS 1.3. Cấm hoàn toàn kết nối HTTP không mã hóa (chỉ trừ môi trường localhost khi dev).
- **SSL/TLS Pinning (Tùy chọn cho bản Release):** Để ngăn chặn tấn công Man-in-the-Middle (MitM), cấu hình SSL Pinning (cố định chứng chỉ máy chủ hoặc public key) trong HTTP Client (`Dio` hoặc `HttpCerts`).

### 3.2. Cơ chế Làm mới Token Tự động (Automatic Token Refresh)
- Access Token có thời hạn ngắn (ví dụ: 15 - 30 phút).
- Khi API Gateway trả về lỗi `401 Unauthorized`, HTTP Interceptor trên Flutter Client phải tự động tạm dừng các request đang chờ, gọi endpoint `/auth/refresh` bằng `refresh_token` từ `flutter_secure_storage`, sau đó thực hiện lại (retry) các request ban đầu một cách trong suốt với người dùng.

---

## 4. Quyền riêng tư & Bảo vệ Dữ liệu Học viên (Privacy & Data Protection)

### 4.1. Xử lý Dữ liệu OCR (Hình ảnh Bài thi viết tay)
- Khi người dùng chụp ảnh bài thi IELTS Writing trên giấy để nhận dạng nét chữ (ML Kit OCR), hình ảnh phải được xử lý ưu tiên **trên thiết bị (On-Device ML)**.
- Trong trường hợp cần tải ảnh lên Cloud để phân tích sâu bằng Gemini Multimodal Vision:
  - Phải thông báo và được sự đồng ý của người dùng (Consent Prompt).
  - Ảnh tải lên phải được xóa khỏi bộ nhớ đệm tạm thời (Temp Directory) của thiết bị ngay sau khi hoàn tất trích xuất văn bản.
  - Máy chủ Backend không được lưu trữ vĩnh viễn ảnh chụp bài làm của người dùng trên Public Storage nếu không phục vụ mục đích lịch sử học tập cá nhân.

### 4.2. Dữ liệu Hội thoại với Trợ lý 3D AI Tutor (Voice & Chat Logs)
- Dữ liệu âm thanh thu từ micro (Speech-to-Text) chỉ được giữ trong bộ nhớ RAM để chuyển đổi thành văn bản, không ghi âm thành file âm thanh lưu trữ lâu dài trên thiết bị.
- Nội dung trò chuyện hỏi đáp với AI Tutor được ẩn danh hóa (Anonymization) khi dùng để cải thiện mô hình NLP.

### 4.3. Quyền Xóa Dữ liệu (Right to be Forgotten - GDPR/PDPA)
- Trong phần Cài đặt của ứng dụng, phải cung cấp chức năng **"Xóa tài khoản và Toàn bộ Dữ liệu" (Delete Account & Data)**.
- Khi người dùng kích hoạt lệnh xóa:
  1. Xóa toàn bộ token và dữ liệu trong `flutter_secure_storage` và `Hive/Isar` cục bộ.
  2. Gửi yêu cầu lên Backend để xóa hoặc vô hiệu hóa vĩnh viễn bản ghi người dùng, lịch sử điểm thi IELTS và tiến độ học tiếng Nhật N5 trong PostgreSQL/Database.

---

## 5. Danh sách Kiểm duyệt Bảo mật cho AI Agents (Security Checklist for AI)

Trước khi thực hiện `commit` hoặc đóng gói bản build, các đại lý AI (`OpenCode`, `MiMo`, `Hermes`) phải tự động rà soát danh sách sau:
- [ ] **No Hardcoded Secrets:** Chạy `grep_search` kiểm tra không có chuỗi `"AIza..."`, `"sk-..."`, `"ey..."` hoặc API Key nào nằm trong thư mục `mobile/lib/` hoặc `backend/src/`.
- [ ] **Secure Storage Use:** Kiểm tra các thông tin token/mật khẩu có được đọc/ghi qua `flutter_secure_storage` thay vì `SharedPreferences` thường hay không.
- [ ] **Sanitize Log Outputs:** Kiểm tra trong các câu lệnh `AppLogger.info()` hoặc `print()` không in ra raw Access Token, mật khẩu hay PII của người dùng.
- [ ] **Rate Limiting Active:** Kiểm tra các endpoint gọi AI Gemini/TTS trên Backend đã gắn Middleware Rate Limiter (ngăn tấn công từ chối dịch vụ DoS/Spam chi phí API).
