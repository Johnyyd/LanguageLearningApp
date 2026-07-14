# 🎌 Đặc Tả Tính Năng (`Slide 3`): Studio Cá Nhân Hóa 3D VTuber & Trợ Lý Đàm Thoại Tiếng Nhật (`AI Custom Avatar Studio & Roleplay Dialogue`)

> **Mục tiêu:** Tập trung 100% vào lộ trình học **Tiếng Nhật (JLPT N5 / N4)**. Nâng cấp và hoàn thiện Trạm Trợ lý 3D AI Tutor (`Slide 3`) với khả năng cá nhân hóa chuyên sâu mô hình 3D VTuber (`.vrm`/`.glb`), tinh chỉnh giọng đọc diễn viên lồng tiếng (Anime VA) và đồng bộ cảm xúc/khẩu hình thời gian thực theo phương pháp `write-spec`.

---

## 🧭 Bối Cảnh & Vấn Đề (Context & Problem)
Theo yêu cầu tập trung toàn bộ ứng dụng vào **Tiếng Nhật**, hệ thống đã loại bỏ/ẩn các mô-đun không liên quan (IELTS). Trạm **Trợ lý 3D AI Tutor & Hỏi đáp Đàm thoại** (`ChatTutorScreen` và `N5DialogueRoleplayScreen`) chính là "linh hồn" giúp người học giao tiếp sống động 1-1 với Sensei. 

Tuy nhiên, hiện tại việc tùy chỉnh 3D Avatar và giọng đọc VA trong `ChatTutorScreen` chỉ dừng ở một modal sheet nhỏ và chưa có khu vực Studio chuyên biệt để người học thử nghiệm các biểu cảm (`mouth_a`, `mouth_i`, `joy`), điều chỉnh tốc độ/cao độ giọng, hay đồng bộ thiết lập sang các trạm học đàm thoại khác.

---

## 🪜 Thang Chi Nhỏ Hợp Đồng (Slice Ladder - `write-spec`)

### `Slice 01`: Phòng Studio Thử Nghiệm Biểu Cảm 3D (`3D Avatar Workbench & Viseme Tester`)
- **Hợp đồng & API Seam:**
  - `ModelViewer` Javascript Bridge cho phép kích hoạt các cờ blendshapes từ Flutter thông qua các hàm điều khiển (`triggerEmotion('happy')`, `triggerViseme('mouth_a')`).
  - Giao diện `AiCustomAvatarStudioScreen` hiển thị mô hình 3D toàn màn hình với thanh công cụ kiểm thử nhanh biểu cảm mặt (`Joy`, `Angry`, `Thinking`, `Blink`) và âm vị khẩu hình (`あ`, `い`, `う`, `え`, `お`).
- **Khả năng Kiểm chứng (Playable Checkpoint):**
  - Người dùng bấm vào nút thử nghiệm "Cười (Joy)" hoặc "Phát âm 'A' (あ)", mô hình 3D Sensei lập tức mỉm cười và mở môi chính xác 100% mà không bị khựng hình.
- **Kiểm thử (Verification):**
  - Kiểm tra không bị lỗi `RenderFlex overflowed` khi mở thanh công cụ blendshape trên màn hình nhỏ.

### `Slice 02`: Bộ Điều Hướng Giọng Đọc Anime VA (`Anime VA Voice Profile Tuner`)
- **Hợp đồng & API Seam:**
  - Tích hợp bộ cấu hình giọng lồng tiếng: `Kana Hanazawa (VA Nữ dịu dàng)`, `Rie Takahashi (VA Nữ năng động)`, `Sensei Male (VA Nam trầm ấm)`.
  - Thanh trượt tinh chỉnh thông số TTS: Tốc độ phát âm (`Speech Rate`: 0.4x - 1.2x) và Cao độ (`Pitch`: 0.8 - 1.4).
- **Khả năng Kiểm chứng (Playable Checkpoint):**
  - Người dùng chọn giọng "Rie Takahashi" và chỉnh Pitch lên `1.2`, sau đó bấm phím "Nghe thử câu mẫu N5". Hệ thống phát âm thanh chuẩn Nhật ngữ đồng thời mô hình 3D nhấp nháy môi theo âm thanh.

### `Slice 03`: Đồng Bộ Persistence Sang Các Trạm Đàm Thoại (`Global Sensei Sync`)
- **Hợp đồng & API Seam:**
  - Lưu trữ cấu hình (`avatarUrl`, `speakerId`, `speechRate`, `pitch`) vào `SharedPreferences` / `ChatBloc`.
  - Khi người dùng sang `ChatTutorScreen` hoặc `N5DialogueRoleplayScreen`, hệ thống tự động tải mô hình và giọng đọc đã được cá nhân hóa trong Studio.
- **Khả năng Kiểm chứng (Playable Checkpoint):**
  - Thay đổi Avatar trong Studio thành mô hình tùy chỉnh, quay lại màn hình chính và mở bài Đàm thoại Konbini $\rightarrow$ Sensei hiển thị đúng mô hình vừa chọn.

---

## 🚀 Next Agent Prompt (Lời Nhắc Cho Đại Lý Tiếp Theo)

> **Tình trạng hiện tại:** Đặc tả kiến trúc Slide 3 đã sẵn sàng tại `specs/ai-custom-avatar-studio/README.md`.
> **Điểm bắt đầu tiếp theo (`Pickup Point`):** Bắt đầu triển khai `Slice 01` & `Slice 02` bằng cách xây dựng màn hình `AiCustomAvatarStudioScreen` (hoặc tích hợp sâu vào `ChatTutorScreen`) và kết nối bộ lưu trữ `SharedPreferences`.
