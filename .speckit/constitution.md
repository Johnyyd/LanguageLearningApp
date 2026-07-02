# 📜 Project Constitution: Language Learning App (Flutter + AI + 3D Avatar)

## 1. Mục đích & Tầm nhìn (Vision & Purpose)
Dự án nhằm xây dựng một ứng dụng di động học ngoại ngữ và luyện thi cao cấp (Premium Portfolio Project), tập trung vào hai mảng chính:
- **Tiếng Nhật cơ bản (N5):** Hiragana, Katakana, Kanji cơ bản với phương pháp ghi nhớ khoa học (Spaced Repetition System - SRS), luyện viết chữ và kiểm tra từ vựng trực quan.
- **Luyện thi IELTS (Writing Task 1):** Hỗ trợ nhập liệu bằng văn bản hoặc chụp ảnh bài viết tay (OCR). Tích hợp Trí tuệ Nhân tạo (AI/NLP) để phân tích cấu trúc câu, chấm điểm theo 4 tiêu chí IELTS, và đề xuất nâng cấp từ vựng/ngữ pháp.
- **Trợ lý Virtual AI Tutor 3D:** Tích hợp mô hình 3D tương tác theo thời gian thực trong giao diện trò chuyện (Q&A), tạo cảm giác học tập sinh động và truyền cảm hứng.

## 2. Nguyên tắc Quản trị Kỹ thuật (Technical Governance Principles)
### 2.1. Kiến trúc & Quản lý State (Architecture & State Management)
- **Clean Architecture:** Phân tách rõ ràng 3 layers: `Domain` (Business Logic/Entities), `Data` (Repositories/Data Sources), và `Presentation` (UI/Widgets/Controllers).
- **Complex State Management:** Sử dụng **BLoC / Cubit** hoặc **Riverpod** làm giải pháp quản lý state chính. Mọi state (đặc biệt là state phân tích AI, tải mô hình 3D, xử lý OCR và đồng bộ dữ liệu) phải được định nghĩa rõ ràng (Loading, Success, Failure, Streaming).
- **Bất biến (Immutability):** Tất cả các Model và State phải mang tính bất biến (sử dụng `freezed` hoặc `equatable`).

### 2.2. Tiêu chuẩn Giao diện & Trải nghiệm Người dùng (UI/UX Standards)
- **Premium Aesthetics:** Thiết kế hiện đại, sử dụng bảng màu hài hòa (Vibrant Colors cho tiếng Nhật, Sleek & Professional cho IELTS), hỗ trợ Dark Mode và Light Mode.
- **Micro-animations:** Tích hợp các hiệu ứng chuyển tiếp mượt mà (Hero transitions, Lottie animations, Shimmer loading) và phản hồi xúc giác (Haptic feedback).
- **Giao diện 3D Model:** Tối ưu hóa việc render mô hình 3D (sử dụng định dạng glTF/GLB nhẹ) để không gây sụt giảm FPS hay tiêu tốn quá nhiều pin/bộ nhớ của thiết bị di động.

### 2.3. Tích hợp AI & Phân tích Ngôn ngữ (NLP Integration)
- **Chuẩn hóa Đầu ra AI:** Backend phải cấu hình các prompt và cấu trúc trả về dạng JSON chuẩn (Structured Outputs) từ AI LLM (Gemini / OpenAI / Claude) để Frontend dễ dàng parse và hiển thị (chấm điểm từng tiêu chí, danh sách lỗi ngữ pháp, từ vựng đề xuất).
- **OCR & Image Processing:** Tối ưu ảnh chụp trước khi gửi lên AI (nén ảnh, căn chỉnh độ tương phản) nhằm đảm bảo độ chính xác khi nhận diện bài viết tay.

### 2.4. Bảo mật & Quản lý Dữ liệu Người dùng (Security & Privacy)
- **Bảo mật Token & Credentials:** Không lưu trữ API Key nhạy cảm ở Frontend. Toàn bộ giao tiếp AI phải thông qua Backend proxy/service.
- **Bảo mật lưu trữ cục bộ:** Sử dụng `flutter_secure_storage` cho Token (JWT/OAuth) và mã hóa cơ sở dữ liệu cục bộ (Hive / Isolate / SQLite với SQLCipher) cho tiến trình học cá nhân.
- **Tuân thủ Quyền riêng tư:** Dữ liệu hình ảnh chụp bài thi và lịch sử trò chuyện được bảo mật, có tùy chọn xóa dữ liệu người dùng.

## 3. Quy chuẩn Kiểm thử & Triển khai (Testing & Deployment)
- **Unit & Widget Tests:** Bao phủ ít nhất 70% Business Logic (BLoC/Cubit) và các Widget cốt lõi.
- **CI/CD Automation:** Quản lý quy trình build và lint code thông qua GitHub Actions (Hermes DevOps).
- **Code Review:** Mọi thay đổi kiến trúc đều phải được kiểm duyệt (MiMo Reviewer) trước khi merge.
