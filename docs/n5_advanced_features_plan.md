# Lộ Trình Triển Khai 3 Tính Năng Nâng Cao N5 (Japanese Learning Enhancement)

Mục tiêu: Đưa ứng dụng học Tiếng Nhật N5 lên tầm cao mới với trải nghiệm tương tác thông minh, trực quan và chuẩn hóa theo kỳ thi JLPT N5.

---

## 🌟 Tính năng 1: Luyện Nghe & Đàm Thoại Ngữ Cảnh N5 (AI Roleplay & Dialogue)
- **Mục tiêu:** Tạo môi trường giao tiếp thực tế với AI Sensei trong các tình huống quen thuộc ở Nhật Bản.
- **Tình huống mẫu:**
  1. 🏪 **Mua sắm tại Konbini (Cửa hàng tiện lợi):** Hỏi giá cả, thanh toán, hâm nóng hộp cơm Bento.
  2. 🚉 **Hỏi đường tại Nhà ga (Eki):** Tìm tàu đi Shinjuku, hỏi giờ tàu chạy, mua vé tàu.
  3. 🍜 **Gọi món tại Nhà hàng (Ramen-ya):** Chọn món, yêu cầu độ cay/ít dầu mỡ, xin hóa đơn thanh toán.
  4. 🤝 **Tự giới thiệu bản thân (Jikoshoukai):** Giới thiệu tên, tuổi, quốc tịch, sở thích và nghề nghiệp.
- **Kiến trúc UI/UX:**
  - Màn hình chọn tình huống đàm thoại thẻ card 3D hiện đại.
  - Khung chat hội thoại 1-1 với hiệu ứng cảm xúc AI Sensei (vui mừng, suy nghĩ, ngạc nhiên).
  - Nút luyện phát âm (Speech-to-Text) và tự động phát âm chuẩn bản xứ (TTS).
  - Chấm điểm độ lưu loát và từ vựng sau mỗi tình huống.

---

## 🧩 Tính năng 2: Trạm Luyện Ngữ Pháp N5 & Sắp Xếp Câu (Grammar Sentence Builder)
- **Mục tiêu:** Nắm vững cấu trúc câu ngữ pháp tiếng Nhật N5 thông qua phương pháp học tương tác trực quan.
- **Các chuyên đề ngữ pháp N5 trọng tâm:**
  1. **Danh từ & Trợ từ cơ bản:** `[N1] は [N2] です`, `[N] を / に / で / が`.
  2. **Động từ thể Lịch sự (Masu-kei):** `~ます`, `~ません`, `~ました`, `~ませんでした`.
  3. **Động từ thể Te (Te-kei):** `~てください` (Hãy làm...), `~ đang làm...`.
  4. **Câu điều kiện & Phán đoán:** `~kará` (Vì...), `~ga` (Nhưng...).
- **Kiến trúc UI/UX:**
  - Bài tập sắp xếp thẻ từ (Drag & Drop / Tap to Order Sentence Builder): Người học bấm vào các khối từ rải rác để ráp thành câu hoàn chỉnh.
  - AI Sensei lập tức xuất hiện giải thích lý do dùng trợ từ/thể từ đó khi người dùng chọn sai hoặc bấm "Hỏi Sensei".

---

## 🏆 Tính năng 3: Đề Thi Thử JLPT N5 Tổng Hợp (Mock Exam & Real-time Timer)
- **Mục tiêu:** Mô phỏng phòng thi chuẩn quốc tế JLPT N5 giúp học viên rèn luyện tâm lý và kiểm tra năng lực toàn diện.
- **Cấu trúc đề thi thu nhỏ (Mini Mock Test N5):**
  1. **Phần 1: Từ vựng & Chữ Hán (Moji - Goi):** 10 câu trắc nghiệm nhanh (Tìm cách đọc Kanji, điền từ vào chỗ trống).
  2. **Phần 2: Ngữ pháp (Bunpou):** 10 câu trắc nghiệm chọn ngữ pháp đúng và bài tập dấu sao (đắp câu).
  3. **Phần 3: Đọc hiểu (Dokkai):** 2 đoạn văn ngắn kèm câu hỏi suy luận.
- **Kiến trúc UI/UX:**
  - Thanh đếm ngược thời gian (Real-time Timer 30 phút) hiển thị trên Header.
  - Bảng tổng kết điểm số kèm phân tích điểm mạnh/điểm yếu từ AI Sensei sau khi nộp bài.
  - Biểu đồ radar hoặc thanh năng lực hiển thị tỷ lệ hoàn thành từng kỹ năng.

---

## 🏗️ Kế hoạch Tích hợp Kiến trúc & Hệ thống (Implementation Plan)
1. **Khởi tạo Dữ liệu mẫu (Seed Data / Datasources):**
   - Thêm các bộ dữ liệu tình huống hội thoại, mẫu câu ngữ pháp N5, và đề thi JLPT N5 mock vào tầng `data/datasources/`.
2. **Xây dựng Màn hình & Components (Presentation Layer):**
   - `DialogueRoleplayScreen` (Luyện Nghe & Đàm Thoại).
   - `GrammarBuilderScreen` (Luyện Ngữ Pháp Kéo-Thả).
   - `JlptMockExamScreen` (Thi Thử JLPT N5).
3. **Cập nhật Dashboard & Quick Actions:**
   - Thêm các lối tắt (Quick Action Cards) và tab điều hướng trên màn hình chính `DashboardScreen` để người học dễ dàng truy cập 3 tính năng mới.
