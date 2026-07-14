# 🌟 Đặc Tả & Lý Do Kiến Trúc 3 Chuyên Đề Nâng Cao N5 (Japanese N5 Advanced Modules)

Tài liệu này ghi nhận **lý do thiết kế (WHY)** và **hợp đồng kiến trúc (Architectural Contracts)** của 3 chuyên đề học tập nâng cao dành cho trình độ Tiếng Nhật JLPT N5. Mã nguồn thực thi và danh sách câu hỏi cụ thể được quản lý bởi các lớp Presentation (Screens) và Data Layer tương ứng.

---

## 1. Trạm Nghe & Đàm Thoại Ngữ Cảnh (`AI Roleplay & Dialogue`)

### 🎯 Lý do Tồn tại (Why)
Học viên N5 thường nắm vững từ vựng và ngữ pháp trên giấy nhưng gặp rào cản lớn khi phản xạ giao tiếp thực tế. Chuyên đề này tạo ra **phòng thí nghiệm giao tiếp an toàn 1-1 với Sensei AI**, mô phỏng các tình huống sinh hoạt thường nhật tại Nhật Bản (Cửa hàng tiện lợi Konbini, Nhà ga Eki, Nhà hàng Ramen, Tự giới thiệu bản thân).

### 🏛️ Hợp đồng & Nguyên tắc Kiến trúc
- **Khối điều khiển & Giao diện:** Nằm tại [n5_dialogue_roleplay_screen.dart](file:///e:/GitHub/LanguageLearningApp/mobile/lib/presentation/screens/n5_dialogue_roleplay_screen.dart).
- **Tương tác Đa phương thức (Multimodal):**
  - **Nhập liệu bằng Giọng nói (Speech-to-Text):** Cho phép học viên luyện phát âm trực tiếp thay vì chỉ gõ phím.
  - **Phản hồi bằng Âm thanh (Text-to-Speech):** Hệ thống phát âm chuẩn bản xứ Nhật Bản, đồng bộ với cử động môi (Lip-syncing).
  - **Biểu cảm 3D Avatar:** Sử dụng [3D Avatar Viewer](file:///e:/GitHub/LanguageLearningApp/mobile/lib/presentation/widgets/common/3d_avatar_viewer.dart) hiển thị trạng thái cảm xúc của Sensei (`thinking`, `talking`, `happy`, `cheering`) dựa trên độ chính xác và trôi chảy của học viên.

---

## 2. Trạm Luyện Ngữ Pháp Kéo-Thả (`Grammar Sentence Builder`)

### 🎯 Lý do Tồn tại (Why)
Ngữ pháp tiếng Nhật N5 có trật tự từ SOV (Chủ - Tân - Động) và hệ thống trợ từ (`は`, `が`, `を`, `に`, `で`) khác biệt hoàn toàn so với tiếng Việt và tiếng Anh. Thay vì trắc nghiệm 4 đáp án thụ động, bài tập **Kéo - Thả / Chạm sắp xếp khối từ (Drag & Drop Sentence Builder)** buộc người học phải tự tư duy trật tự logic của toàn bộ câu.

### 🏛️ Hợp đồng & Nguyên tắc Kiến trúc
- **Khối điều khiển & Giao diện:** Nằm tại [n5_grammar_builder_screen.dart](file:///e:/GitHub/LanguageLearningApp/mobile/lib/presentation/screens/n5_grammar_builder_screen.dart).
- **Nguyên tắc Tối ưu Không gian (Clean Workspace Focus):**
  - Để đảm bảo diện tích hiển thị tối đa cho các khối từ (Pills) và khu vực xếp câu trên màn hình di động, giao diện này **chủ ý loại bỏ header 3D Avatar**.
  - Toàn bộ body sử dụng `ResponsiveContainer` và khối phản hồi AI Sensei dạng thẻ chữ (Text Card) sắc nét, giúp học viên thao tác nhanh chóng không bị phân tâm.
- **Nguồn Dữ liệu Ngữ pháp:** Xử lý qua [RemoteAiDataSource](file:///e:/GitHub/LanguageLearningApp/mobile/lib/data/datasources/remote_ai_datasource.dart) với khả năng tải động các bài tập từ AI Backend hoặc fallback về bộ câu hỏi chuẩn hóa offline.

---

## 3. Đề Thi Thử JLPT N5 Tổng Hợp (`Mock Exam & Real-time Timer`)

### 🎯 Lý do Tồn tại (Why)
Mô phỏng áp lực thời gian và cấu trúc đa kỹ năng của kỳ thi JLPT N5 chuẩn quốc tế, giúp học viên đánh giá chính xác năng lực trước khi bước vào phòng thi thật.

### 🏛️ Hợp đồng & Nguyên tắc Kiến trúc
- **Khối điều khiển & Giao diện:** Nằm tại [n5_jlpt_mock_exam_screen.dart](file:///e:/GitHub/LanguageLearningApp/mobile/lib/presentation/screens/n5_jlpt_mock_exam_screen.dart).
- **Cấu trúc Đa kỹ năng (Multi-Skill Assessment):**
  1. **Moji - Goi (Từ vựng & Chữ Hán):** Kiểm tra cách đọc Kanji và chọn từ phù hợp ngữ cảnh.
  2. **Bunpou (Ngữ pháp):** Bài tập điền trợ từ và trắc nghiệm cấu trúc.
  3. **Dokkai (Đọc hiểu):** Đoạn văn ngắn kèm câu hỏi suy luận logic.
- **Đồng hồ Canh giờ Thời gian thực (Real-time Timer):**
  - Bộ đếm ngược tự động khóa bài thi khi hết giờ.
  - Sau khi nộp bài, hệ thống tính toán điểm số và gọi API AI Sensei để tạo **Báo cáo Phân tích Điểm mạnh/Điểm yếu** cho học viên.

---

## 🧭 Điều Hướng Thao Tác (Navigation Pointers)
- Trải nghiệm tổng hợp của cả 3 chuyên đề được kết nối liền mạch từ Dashboard thông qua các thẻ **Quick Action Cards** tại [dashboard_screen.dart](file:///e:/GitHub/LanguageLearningApp/mobile/lib/presentation/screens/dashboard_screen.dart).
