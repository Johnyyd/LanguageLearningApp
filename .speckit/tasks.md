# 📋 Task Decomposition: Language Learning & IELTS AI Assistant

## 1. Giai đoạn 1: Khảo sát, Cấu hình Hạ tầng & Thiết lập Dự án (Infrastructure & Project Setup)
- [ ] **TASK-1.1 [Hermes - DevOps/Hạ tầng]:** Khởi tạo cấu trúc dự án Flutter 3.x với kiến trúc Clean Architecture (`domain`, `data`, `presentation`), thiết lập các package phụ thuộc (`flutter_bloc`, `freezed`, `hive`, `flutter_secure_storage`, `flutter_3d_controller`, `google_mlkit_text_recognition`).
- [ ] **TASK-1.2 [Hermes - DevOps/Hạ tầng]:** Thiết lập môi trường Backend AI Gateway (Node.js NestJS hoặc Python FastAPI), cấu hình kết nối cơ sở dữ liệu PostgreSQL/Prisma và viết Dockerfile, docker-compose.yml cho development.
- [ ] **TASK-1.3 [Hermes - DevOps/Hạ tầng]:** Cấu hình GitHub Actions CI/CD pipeline để tự động lint code Dart/Flutter, kiểm tra build tĩnh và chạy unit tests khi tạo Pull Request.
- [ ] **TASK-1.4 [MiMo - Phân tích/Reviewer]:** Kiểm duyệt kiến trúc thư mục ban đầu và cấu hình bảo mật biến môi trường (API Key management, CORS, SSL).

## 2. Giai đoạn 2: Xây dựng Core Framework & Quản lý State (Core Architecture & State Management)
- [ ] **TASK-2.1 [OpenCode - Thợ code chính]:** Xây dựng tầng Core Network Client (Dio HTTP Client với Interceptors) có xử lý tự động làm mới JWT Token và quản lý lỗi kết nối ngoại tuyến/trực tuyến.
- [ ] **TASK-2.2 [OpenCode - Thợ code chính]:** Thiết lập cơ sở dữ liệu cục bộ (Hive/Isar) cho tính năng học Offline; tạo các Repository pattern và Data Source interfaces cho việc đồng bộ hóa dữ liệu trên Cloud.
- [ ] **TASK-2.3 [Antigravity - Điều phối/Thợ code phụ]:** Viết các tiện ích hỗ trợ (Helper utilities): Validators cho form đăng nhập/đăng ký, định dạng thời gian, xử lý chuỗi và hệ thống Design System (Theme, Colors, Typography theo chuẩn UI/UX cao cấp).

## 3. Giai đoạn 3: Phát triển Module Tiếng Nhật N5 (Japanese Vocabulary & Handwriting Module)
- [ ] **TASK-3.1 [OpenCode - Thợ code chính]:** Triển khai thuật toán Spaced Repetition System (SRS SuperMemo-2) trong tầng Domain; xây dựng `VocabSrsBloc` quản lý trạng thái thẻ Flashcard (Again, Hard, Good, Easy) và tính toán thời gian ôn luyện tiếp theo.
- [ ] **TASK-3.2 [OpenCode - Thợ code chính]:** Xây dựng tính năng Nhận diện nét chữ (Handwriting Stroke Recognition & Order Verification) trên nền màn hình vẽ cảm ứng (Canvas CustomPainter).
- [ ] **TASK-3.3 [Antigravity - Điều phối/Thợ code phụ]:** Xây dựng giao diện thẻ Flashcard xoay 3D (Flip Card UI), màn hình danh sách từ vựng Hiragana/Katakana/Kanji và màn hình Quiz trắc nghiệm kèm micro-animations (Lottie).
- [ ] **TASK-3.4 [MiMo - Phân tích/Reviewer]:** Review logic tính toán chu kỳ SRS và kiểm tra hiệu năng cảm ứng khi vẽ chữ Kana trên thiết bị thực tế.

## 4. Giai đoạn 4: Phát triển Module IELTS Writing Task 1 & OCR (IELTS Writing & OCR Module)
- [ ] **TASK-4.1 [OpenCode - Thợ code chính]:** Tích hợp Google ML Kit Text Recognition vào ứng dụng Flutter để nhận diện văn bản bước đầu từ ảnh chụp bài thi viết tay; xây dựng màn hình xem trước và chỉnh sửa kết quả OCR.
- [ ] **TASK-4.2 [OpenCode - Thợ code chính]:** Xây dựng `IeltsEvalBloc` và tích hợp API kết nối với AI Gateway Backend để gửi bài viết (hoặc ảnh chụp) lên mô hình Gemini 1.5 Pro Multimodal.
- [ ] **TASK-4.3 [OpenCode - Thợ code chính]:** Phát triển dịch vụ Backend AI Evaluator Service: Cấu hình System Prompt chuẩn cho Gemini để chấm điểm chính xác 4 tiêu chí IELTS Writing Task 1, trả về JSON chuẩn xác định vị trí lỗi ngữ pháp và từ vựng nâng cao.
- [ ] **TASK-4.4 [Antigravity - Điều phối/Thợ code phụ]:** Xây dựng giao diện Báo cáo Chấm điểm AI (AI Grading Report UI): Biểu đồ radar hiển thị 4 tiêu chí band score, danh sách lỗi ngữ pháp có highlight đỏ/xanh và thẻ đề xuất từ vựng học thuật.
- [ ] **TASK-4.5 [MiMo - Phân tích/Reviewer]:** Đánh giá độ chính xác của cấu trúc JSON trả về từ AI, kiểm tra tính kiên cố (robustness) khi người dùng chụp ảnh mờ hoặc bài viết chữ thảo (cursive handwriting).

## 5. Giai đoạn 5: Tích hợp Trợ lý 3D AI Tutor & Hỏi đáp Trực tuyến (3D Avatar & Interactive Q&A)
- [ ] **TASK-5.1 [OpenCode - Thợ code chính]:** Tích hợp package `flutter_3d_controller` / `model_viewer_plus`; xây dựng component `3d_avatar_widget` tải mô hình `.glb` nhẹ (dưới 3MB) và kết nối bộ điều khiển animation với các sự kiện trong App.
- [ ] **TASK-5.2 [OpenCode - Thợ code chính]:** Xây dựng tính năng Trò chuyện trực tuyến (Chat Q&A Service) sử dụng WebSockets/SSE kết nối tới Backend AI; hỗ trợ cả nhập liệu bằng văn bản (Text) và giọng nói (Speech-to-Text).
- [ ] **TASK-5.3 [Antigravity - Điều phối/Thợ code phụ]:** Xây dựng giao diện Phòng trò chuyện (Chatroom UI) tích hợp 3D Avatar ở phần trên màn hình; đồng bộ chuyển động của avatar (`idle`, `talking`, `happy`, `thinking`) theo trạng thái trả lời của AI và tích hợp Text-to-Speech (TTS).
- [ ] **TASK-5.4 [MiMo - Phân tích/Reviewer]:** Kiểm tra FPS và mức tiêu hao bộ nhớ/pin khi render mô hình 3D trong suốt phiên trò chuyện dài; kiểm thử bảo mật các cổng kết nối WebSocket.

## 6. Giai đoạn 6: Hoàn thiện, Tối ưu hóa UI/UX & Đóng gói Portfolio (Polish & Verification)
- [x] **TASK-6.1 [Antigravity - Điều phối/Thợ code phụ]:** Hoàn thiện các hiệu ứng chuyển tiếp (Hero animations, Shimmer loading), tinh chỉnh bảng màu Dark/Light mode và bổ sung đồ họa/biểu tượng chất lượng cao cho toàn app.
- [ ] **TASK-6.2 [OpenCode - Thợ code chính]:** Viết tài liệu README.md chi tiết, tài liệu hướng dẫn cài đặt, kiến trúc hệ thống và tạo dữ liệu giả lập (Demo Seed Data) để phô diễn tính năng cho Portfolio.
- [ ] **TASK-6.3 [Hermes - DevOps/Hạ tầng]:** Đóng gói Docker container cho Backend, chuẩn bị kịch bản build bản cài đặt APK (Android) và IPA (iOS) cho mục đích demo.
- [x] **TASK-6.4 [MiMo - Phân tích/Reviewer]:** Thực hiện kiểm duyệt cuối cùng theo quy chuẩn convergence (`/speckit.converge`); kiểm tra tuân thủ toàn bộ các nguyên tắc hiến pháp dự án (`/speckit.constitution`).
