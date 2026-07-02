# 🎯 Functional Specification: Language Learning & IELTS AI Assistant

## 1. Tổng quan Sản phẩm (Product Overview)
Ứng dụng di động trên nền tảng Flutter kết hợp Trí tuệ nhân tạo (AI/NLP) và mô hình 3D tương tác, mang đến trải nghiệm cá nhân hóa toàn diện cho hai đối tượng học tập:
1. Người mới bắt đầu học Tiếng Nhật (Mức độ N5: Hiragana, Katakana, Kanji).
2. Thí sinh ôn luyện thi IELTS (Tập trung vào Writing Task 1 và phát triển vốn từ vựng học thuật).

## 2. Đặc tả Tính năng Chi tiết (Detailed Feature Specifications)

### 2.1. Module 1: Luyện từ vựng Tiếng Nhật N5 (Japanese N5 Module)
- **REQ-JAP-01 (Hệ thống Flashcard & SRS):**
  - Hiển thị thẻ từ vựng với chữ Hán/Kana, phiên âm Romaji, nghĩa tiếng Việt/Anh và câu ví dụ.
  - Sử dụng thuật toán lặp lại ngắt quãng (Spaced Repetition System - SRS Anki/SM-2) để tự động sắp xếp lịch ôn tập theo các mức độ ghi nhớ (Again, Hard, Good, Easy).
- **REQ-JAP-02 (Luyện viết & Nhận diện nét chữ - Stroke Order):**
  - Hiển thị hình ảnh hướng dẫn thứ tự nét viết (Stroke order animation).
  - Bảng vẽ cảm ứng (Canvas) cho phép người dùng dùng ngón tay/bút vẽ lại chữ Kana/Kanji; hệ thống tự động kiểm tra độ chính xác của nét vẽ.
- **REQ-JAP-03 (Kiểm tra & Nghe phát âm):**
  - Các bài kiểm tra nhanh (Trắc nghiệm, Ghép cặp thẻ, Nghe chọn từ đúng).
  - Phát âm bản ngữ chuẩn xác (Native Audio/TTS chất lượng cao).

### 2.2. Module 2: Luyện viết IELTS Writing Task 1 & AI Chấm điểm (IELTS Writing AI Coach)
- **REQ-IELTS-01 (Thư viện Đề bài & Biểu đồ):**
  - Cung cấp kho đề thi mẫu phân loại theo dạng biểu đồ: Line graph, Bar chart, Pie chart, Table, Process/Map diagram.
- **REQ-IELTS-02 (Đa phương thức Nhập bài - Text & OCR Camera):**
  - **Nhập văn bản trực tiếp:** Trình soạn thảo văn bản tích hợp đếm từ (Word count), canh thời gian làm bài (Countdown timer 20 phút).
  - **Chụp ảnh bài viết tay (Camera/Photo OCR):** Người dùng chụp ảnh bài viết trên giấy; hệ thống sử dụng OCR AI để chuyển đổi thành văn bản kỹ thuật số, cho phép người dùng xem lại và chỉnh sửa trước khi nộp.
- **REQ-IELTS-03 (Phân tích NLP & Chấm điểm chuyên sâu):**
  - **Dự đoán Band Score:** Chấm điểm theo 4 tiêu chí IELTS (Task Achievement, Cohesion & Coherence, Lexical Resource, Grammatical Range & Accuracy) kèm điểm tổng quát (Overall Band Score).
  - **Phân tích Cấu trúc & Lỗi Ngữ pháp:** Highlight các lỗi sai ngữ pháp, dấu câu, chia thì; giải thích nguyên nhân lỗi và đưa ra câu sửa hoàn chỉnh (Corrected Version).
  - **Đề xuất Từ vựng Học thuật (Lexical Upgrade):** Nhận diện các từ vựng thông thường (hàng ngày) và gợi ý các từ/cụm từ học thuật, collocation nâng cao phù hợp với ngữ cảnh mô tả số liệu/xu hướng.

### 2.3. Module 3: Trợ lý AI 3D & Trò chuyện Hỏi đáp (3D AI Tutor & Interactive Q&A)
- **REQ-3D-01 (Giao diện Avatar 3D Tương tác):**
  - Tích hợp nhân vật 3D (Sensei / Tutor Avatar) ngay trong màn hình trò chuyện và trang chủ.
  - Mô hình 3D có khả năng thực hiện các hoạt ảnh (Animations): Gật đầu chào, nói chuyện (lively lip-syncing/gestures), suy nghĩ khi AI đang xử lý, vui mừng khi người dùng làm đúng hoặc đạt band điểm cao.
- **REQ-3D-02 (Hỏi đáp & Trò chuyện Tự nhiên - Q&A Chatbot):**
  - Người dùng có thể nhắn tin (Text) hoặc nói (Speech-to-Text) để hỏi trợ lý AI về bất kỳ thắc mắc nào (VD: *"Phân biệt trợ từ Wa và Ga trong tiếng Nhật như thế nào?"* hoặc *"Làm sao để viết mở bài Paraphrase cho biểu đồ tròn này?"*).
  - Trợ lý AI trả lời tức thì với giọng văn thân thiện, sư phạm, kèm giải thích dễ hiểu và dẫn chứng cụ thể.
- **REQ-3D-03 (Text-to-Speech & Voice Feedback):**
  - Trợ lý AI có thể đọc câu trả lời bằng giọng nói tự nhiên (Voice synthesis - Tiếng Anh/Tiếng Nhật/Tiếng Việt) đồng bộ với chuyển động của mô hình 3D.

### 2.4. Module 4: Quản lý Dữ liệu Cá nhân & Bảo mật (User Profile & Security)
- **REQ-SEC-01 (Xác thực Người dùng):**
  - Đăng ký/Đăng nhập bảo mật qua JWT Token (hỗ trợ Google Auth, Apple ID).
- **REQ-SEC-02 (Bảng điều khiển Tiến độ - Progress Dashboard):**
  - Biểu đồ theo dõi chuỗi ngày học liên tục (Streak), số lượng từ vựng N5 đã thuộc, và lịch sử sự tiến bộ của điểm IELTS Writing theo thời gian.
- **REQ-SEC-03 (Bảo mật Dữ liệu & Chế độ Ngoại tuyến):**
  - Dữ liệu từ vựng và lịch sử học tập được mã hóa và lưu trữ cục bộ để có thể học Offline; tự động đồng bộ lên Cloud (PocketBase / Supabase / Node.js Backend) khi có kết nối mạng.

## 3. Quy trình Trải nghiệm Người dùng (User Workflows)

### Workflow 1: Luyện viết và Nhận nhận xét IELTS từ AI
`[Chọn đề bài Writing Task 1]` -> `[Chụp ảnh bài viết tay hoặc Gõ văn bản]` -> `[Xác nhận văn bản OCR]` -> `[Gửi lên AI Backend]` -> `[Nhận Báo cáo Chấm điểm 4 tiêu chí & Đề xuất nâng cấp từ vựng]` -> `[Hỏi đáp thêm với Trợ lý 3D AI về các lỗi sai]`.

### Workflow 2: Học Từ vựng Tiếng Nhật N5 với Trợ lý 3D
`[Mở gói từ vựng N5]` -> `[Xem thẻ Flashcard & Nghe phát âm]` -> `[Luyện vẽ nét chữ Kana/Kanji trên màn hình]` -> `[Làm bài kiểm tra ngắn]` -> `[Trợ lý 3D biểu lộ cảm xúc chúc mừng & cập nhật điểm SRS]`.

## 4. Tiêu chí Chấp nhận (Acceptance Criteria)
- Ứng dụng hoạt động mượt mà trên iOS và Android ở mức 60 FPS (kể cả khi hiển thị mô hình 3D).
- Thời gian phản hồi phân tích OCR và chấm điểm bài viết IELTS của AI không quá 10 giây trong điều kiện mạng tiêu chuẩn.
- Dữ liệu token và thông tin cá nhân được mã hóa an toàn tại tầng `flutter_secure_storage`.
