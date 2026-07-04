# 🎨 Quy chuẩn Giao diện UI/UX & Trợ lý 3D Avatar (UI/UX & 3D Avatar Design System)

Tài liệu này là hướng dẫn chuẩn mực cho việc thiết kế, xây dựng các thành phần giao diện (UI components), tối ưu trải nghiệm người dùng (UX) và tích hợp mô hình **3D Avatar tương tác trực tiếp** trong ứng dụng **Language Learning & IELTS AI Assistant**.

> [!TIP]
> **Triết lý Thiết kế: Premium Portfolio Design**
> Ứng dụng phải tạo được ấn tượng thị giác mạnh mẽ ngay từ cái nhìn đầu tiên (WOW factor). Sử dụng bảng màu hiện đại, typography sắc nét từ Google Fonts, kính mờ (Glassmorphism), gradient mượt mà và các hiệu ứng chuyển động nhỏ (Micro-animations) để thổi hồn vào trải nghiệm học tập.

---

## 1. Hệ thống Ngôn ngữ Thiết kế (Design System Tokens)

### 1.1. Bảng màu Chủ đạo (Curated Color Palettes)
Hệ thống sử dụng hai bảng màu riêng biệt được tinh chỉnh cho từng ngữ cảnh học tập, kết hợp với chế độ Tối/Sáng (Dark/Light Mode) liền mạch:

| Module / Ngữ cảnh | Tên màu (Color Token) | Mã HEX | Mục đích & Vị trí áp dụng |
| :--- | :--- | :--- | :--- |
| **Tiếng Nhật N5** | `Sakura Pink` (Primary) | `#FF85A2` | Nút bấm chính, viền thẻ Flashcard, thanh tiến độ học Kana. |
| *(Japanese Module)*| `Deep Indigo` (Background)| `#1A1E36` | Màu nền chủ đạo trong chế độ Dark Mode, mang lại cảm giác sâu thẳm, tập trung. |
| | `Zen Bamboo Green` (Success)| `#10B981` | Đánh dấu nét vẽ Kanji đúng, câu trả lời Quiz chính xác, điểm SRS Easy. |
| **IELTS Writing** | `Academic Navy` (Primary) | `#0F172A` | Màu nền trang trọng, chuẩn mực học thuật cho phòng thi IELTS Writing. |
| *(IELTS Module)* | `Gold Accent` (Highlight) | `#F59E0B` | Đánh dấu các từ vựng học thuật cao cấp (Lexical Upgrade), điểm Band 8.0+. |
| | `Coral Red` (Error/Alert) | `#EF4444` | Highlight các lỗi sai ngữ pháp, dấu câu trong bài viết IELTS OCR. |
| **Chung (Universal)**| `Glass White` (Surface) | `rgba(255,255,255,0.08)`| Thẻ nền Glassmorphism với độ mờ backdrop-blur 12px. |

### 1.2. Nghệ thuật Chữ (Typography - Google Fonts)
- **Font chính (UI & English/IELTS):** `Inter` hoặc `Outfit` – hiện đại, dễ đọc trên màn hình di động ở mọi kích thước.
- **Font tiếng Nhật (Kana & Kanji):** `Noto Sans JP` hoặc `Kosugi Maru` – đảm bảo hiển thị rõ ràng từng nét khắc của chữ Hán và Kana, hỗ trợ tốt cho việc hướng dẫn thứ tự nét vẽ (Stroke Order).

---

## 2. Chuẩn hóa Các Thành phần Giao diện Cốt lõi (Core Components)

### 2.1. Thẻ Flashcard Xoay 3D (3D Flip Flashcard - N5 Module)
- **Yêu cầu tương tác:** Chạm hoặc vuốt nhẹ để lật thẻ giữa mặt trước (Kanji/Kana + Audio Button) và mặt sau (Nghĩa tiếng Việt/Anh + Romaji + Câu ví dụ).
- **Hiệu ứng vật lý:** Sử dụng `Transform(transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle))` với đường cong chuyển động `Curves.easeInOutCubic` (thời lượng 400ms).

### 2.2. Bảng vẽ Cảm ứng Luyện chữ (Handwriting Canvas)
- **CustomPainter & Touch Tracking:** Sử dụng `CustomPaint` để ghi nhận tọa độ ngón tay/bút vẽ với tốc độ lấy mẫu cao (mượt mà không bị đứt nét).
- **Phản hồi xúc giác (Haptic Feedback):**
  - Khi viết đúng thứ tự nét (Stroke Order matching): Phát rung nhẹ (`HapticFeedback.lightImpact()`).
  - Khi viết sai hoặc vẽ chệch hướng: Phát rung cảnh báo (`HapticFeedback.vibrate()`) kèm nháy viền màu đỏ nhạt.

### 2.3. Màn hình Đối chiếu & Chấm điểm IELTS (AI Grading Dashboard)
- **Biểu đồ Radar 4 Tiêu chí:** Sử dụng biểu đồ radar (như gói `fl_chart`) để hiển thị trực quan cân bằng điểm số giữa *Task Achievement*, *Coherence*, *Lexical*, và *Grammar*.
- **Smart Text Highlight:** Đoạn văn bản IELTS sau khi chấm sẽ có các từ/cụm từ được gạch chân màu sắc theo loại lỗi. Khi học viên chạm vào từ bị lỗi, một BottomSheet Glassmorphism sẽ trượt lên hiển thị nguyên nhân và câu sửa gợi ý từ AI.

---

## 3. Tích hợp Trợ lý 3D Avatar Tương tác (3D AI Tutor Integration)

### 3.1. Công nghệ Render & Quản lý Mô hình
- Sử dụng thư viện `model_viewer_plus` hoặc `flutter_3d_controller` để render mô hình định dạng `.glb` / `.gltf` nhẹ (dung lượng tối ưu dưới 3MB/mô hình để đảm bảo tải nhanh và không gây trễ FPS).
- Mô hình 3D (nhân vật **Sensei** cho Tiếng Nhật hoặc **IELTS Examiner** cho IELTS) được bố trí ở nửa trên hoặc góc màn hình hội thoại Q&A.

### 3.2. Đồng bộ Hoạt ảnh với Trạng thái AI (Animation State Sync)
Trạng thái của 3D Avatar phải được điều khiển trực tiếp bởi `BLoC/Cubit` dựa trên luồng phản hồi của AI Gateway và Text-to-Speech (TTS):

```mermaid
stateDiagram-v2
    [*] --> Idle: Mở màn hình Chat / Home
    Idle --> Greeting: Người dùng bước vào bài học mới
    Greeting --> Idle: Hoàn tất chào hỏi (3s)
    
    Idle --> Thinking: Người dùng gửi câu hỏi Q&A / Nộp bài IELTS
    Thinking --> Talking: AI Gateway trả lời lời giải + Audio TTS streaming
    Talking --> Idle: Kết thúc phát âm thanh TTS
    
    Idle --> Cheering: Học viên đạt điểm cao / Hoàn thành gói SRS N5
    Cheering --> Idle: Hoàn tất chúc mừng (4s)
```

| Trạng thái Avatar (`State`) | Hoạt ảnh 3D (`Animation Name`) | Kích hoạt khi nào? |
| :--- | :--- | :--- |
| `idle` | `Idle_Breathing` / `Blink` | Trạng thái nghỉ mặc định, nhân vật thở nhẹ, thỉnh thoảng chớp mắt tự nhiên. |
| `greeting` | `Bow_Welcome` / `Wave_Hand` | Khi người dùng vừa mở app hoặc chọn vào module học tập. |
| `thinking` | `Hand_On_Chin` / `Pondering` | Trong khi chờ gọi API Gemini chấm bài IELTS hoặc phân tích câu hỏi khó (độ trễ 2-8s). |
| `talking` | `Talk_LipSync` / `Explain_Gesture`| Đồng bộ chính xác với thời điểm luồng âm thanh TTS đang phát ra loa/tai nghe. |
| `cheering` | `Clap_Hands` / `Happy_Jump` | Khi người dùng hoàn thành xuất sắc bài kiểm tra hoặc đạt Band IELTS từ 7.0 trở lên. |

---

## 4. Tối ưu Hóa Hiệu năng & Micro-animations (Performance & Polish)

### 4.1. Tiêu chí 60 FPS (Silky Smooth Performance)
- **Cấm Block UI Thread:** Các tác vụ tính toán nặng như chuyển đổi ảnh chụp bài thi IELTS sang chuẩn Base64 cho OCR, hoặc tính toán lịch lặp lại ngắt quãng SRS phải được thực thi trong background isolate (`compute()` hoặc `Isolate`).
- **Tối ưu 3D Render:** Khi người dùng cuộn khỏi màn hình có 3D Avatar hoặc tạm ẩn ứng dụng xuống nền, tạm dừng vòng lặp render 3D (`pauseAnimation()`) để tiết kiệm pin và bộ nhớ GPU.

### 4.2. Shimmer Loading & Transitions
- **Shimmer Skeletons:** Khi đang fetch dữ liệu bài học từ AI Gateway hoặc tải danh sách từ vựng, bắt buộc hiển thị khung xương Shimmer (mờ nhấp nháy màu Sakura Pink nhạt hoặc Navy nhạt) thay vì vòng quay loading (`CircularProgressIndicator`) đơn điệu.
- **Page Transitions:** Chuyển màn hình sử dụng hiệu ứng vuốt mượt mà kiểu iOS (Cupertino Page Transition) hoặc Fade-through theo chuẩn Material Design 3.

---

## 5. Hướng dẫn Kiểm tra UI/UX cho AI Agents (UI QA Checklist)

Khi đại lý `MiMo` hoặc `Antigravity` kiểm tra giao diện, hãy xác nhận các tiêu chí sau:
- [ ] **No Overflow Errors:** Kiểm tra trên màn hình kích thước nhỏ (như iPhone SE hoặc Android màn hình nhỏ) không bị lỗi dải màu vàng đen `A RenderFlex overflowed by x pixels`.
- [ ] **Contrast Ratio:** Văn bản tiếng Nhật và tiếng Anh phải có độ tương phản đủ cao so với màu nền (đặc biệt trên nền Glassmorphism) theo chuẩn WCAG AA.
- [ ] **3D State Responsiveness:** Kiểm tra khi chuyển từ trạng thái `thinking` sang `talking`, mô hình 3D không bị khựng (freeze/glitch) hoặc mất mô hình.
