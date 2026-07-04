# 🏛️ Tiêu chuẩn Kỹ thuật & Kiến trúc Lập trình cho AI (AI Coding Standards & Architecture)

Tài liệu này xác định các quy tắc kiến trúc, thiết kế phần mềm và nguyên tắc viết mã bắt buộc đối với tất cả các đại lý AI (`OpenCode`, `Antigravity`, `Hermes`, `MiMo`) cũng như các lập trình viên khi tham gia phát triển dự án **Language Learning & IELTS AI Assistant**.

> [!IMPORTANT]
> **Tuân thủ tuyệt đối quy định GitNexus & Clean Architecture:** Mọi thay đổi mã nguồn phải được đánh giá tác động trước khi thực hiện. Phân tách rõ ràng các tầng trách nhiệm để đảm bảo tính dễ bảo trì, dễ kiểm thử và mở rộng ứng dụng trong tương lai.

---

## 1. Nguyên tắc GitNexus Code Intelligence (BẮT BUỘC)

Theo hiến pháp dự án và quy tắc trong `AGENTS.md`, mọi đại lý AI trước và sau khi viết code phải tuân thủ nghiêm ngặt các lệnh GitNexus:

1. **Phân tích Tác động (Blast Radius Assessment):**
   - **KHÔNG BAO GIỜ** được phép chỉnh sửa một hàm, lớp (class), hoặc phương thức mà không chạy lệnh `gitnexus_impact({target: "symbolName", direction: "upstream"})` trước.
   - Báo cáo rõ ràng phạm vi ảnh hưởng (các caller trực tiếp, các luồng thực thi bị ảnh hưởng, mức độ rủi ro: LOW/MEDIUM/HIGH/CRITICAL) cho người dùng biết.
   - Nếu mức độ rủi ro là **HIGH** hoặc **CRITICAL**, phải cảnh báo và xác nhận kỹ trước khi tiến hành sửa code.
2. **Khám phá Mã nguồn (Code Exploration):**
   - Khi tìm hiểu mã nguồn unfamiliar, sử dụng `gitnexus_query({query: "concept"})` để tìm các luồng thực thi thay vì grep thô.
   - Khi cần bối cảnh đầy đủ về một symbol (ai gọi nó, nó gọi ai, tham gia vào luồng nào), dùng `gitnexus_context({name: "symbolName"})`.
3. **Refactoring & Đổi tên (Renaming):**
   - **KHÔNG BAO GIỜ** dùng lệnh Find-and-Replace để đổi tên biến, hàm hay class. Bắt buộc phải dùng `gitnexus_rename` để hệ thống tự động cập nhật đúng call graph.
4. **Kiểm tra trước khi Commit:**
   - Luôn chạy `gitnexus_detect_changes()` trước khi commit để xác nhận các thay đổi chỉ tác động trong phạm vi mong đợi.

---

## 2. Kiến trúc Clean Architecture & BLoC Pattern (Flutter Mobile)

Ứng dụng Flutter được tổ chức theo chuẩn **Clean Architecture** kết hợp với **BLoC (Business Logic Component)** để quản lý state phức tạp.

```
mobile/lib/
├── core/                   # Cấu hình chung, constants, utils, lỗi, theme
├── domain/                 # Tầng logic nghiệp vụ (ĐỘC LẬP HOÀN TOÀN)
│   ├── entities/           # Các lớp đối tượng dữ liệu thuần (Dart objects)
│   ├── repositories/       # Interfaces defining data operations
│   └── usecases/           # Các hành động cụ thể (VD: EvaluateIeltsEssayUseCase)
├── data/                   # Tầng xử lý dữ liệu (Triển khai interfaces của Domain)
│   ├── datasources/        # Remote AI Gateway (Dio) & Local DB (Hive/Isar)
│   ├── models/             # DTOs, JSON parsing, Serialization (Freezed/JsonSerializable)
│   └── repositories/       # Implementations của domain/repositories
└── presentation/           # Tầng giao diện người dùng (UI & State)
    ├── blocs/              # BLoCs và Cubits quản lý trạng thái màn hình
    ├── pages/              # Các màn hình chính (Screens/Views)
    └── widgets/            # Các thành phần UI tái sử dụng (Flashcards, Canvas, Avatar 3D)
```

### 2.1. Quy tắc Viết mã cho từng Tầng
- **Tầng Domain (`domain/`):**
  - **KHÔNG** import bất kỳ gói nào của Flutter (`package:flutter/...`) hoặc các gói bên thứ ba như Dio, Hive, Shared Preferences. Tầng này chỉ chứa Dart thuần (`dart:async`, `dart:math`...) và gói tiện ích functional programming (như `dartz` / `fpdart` cho `Either`).
  - Mọi logic nghiệp vụ cốt lõi như thuật toán tính toán lịch lặp lại ngắt quãng **Spaced Repetition (SRS SuperMemo-2)** phải được viết ở tầng Domain.
- **Tầng Data (`data/`):**
  - Các lớp Model phải kế thừa hoặc chuyển đổi mượt mà sang Entity của Domain (`model.toEntity()`).
  - Khuyến khích sử dụng package `freezed` và `json_serializable` để tạo tính bất biến (Immutability) cho Models.
- **Tầng Presentation (`presentation/`):**
  - UI chỉ giao tiếp với logic thông qua `BLoC` hoặc `Cubit`. Cấm gọi trực tiếp Data Source hay Repository từ phía các Widget.
  - Sử dụng `BlocBuilder` để vẽ UI theo State và `BlocListener` để xử lý các hiệu ứng một lần (One-off events như hiện SnackBar lỗi, rung Haptic, chuyển màn hình).

---

## 3. Tiêu chuẩn Mã hóa Thuật toán & Tính năng Cốt lõi

### 3.1. Thuật toán Spaced Repetition (SRS SuperMemo-2) cho Tiếng Nhật N5
Khi lập trình thuật toán SRS trong `Domain UseCase`, các AI Agents phải tuân thủ chuẩn toán học của Anki/SM-2:
- **Tham số đầu vào:** Điểm đánh giá của người dùng từ 0 đến 5 (trong app chia làm 4 nút: `Again = 1`, `Hard = 2`, `Good = 4`, `Easy = 5`).
- **Công thức cập nhật E-Factor (Easiness Factor):**
  $$\text{EF}' = \max\left(1.3, \, \text{EF} + 0.1 - (5 - q) \times (0.08 + (5 - q) \times 0.02)\right)$$
- **Tính chu kỳ lặp lại (Interval - ngày):**
  - Nếu $q < 3$ (Quên/Again/Hard): $\text{Interval} = 1$, Lặp lại số lần liên tiếp $n = 0$.
  - Nếu $q \ge 3$:
    - $n = 1 \implies \text{Interval} = 1$
    - $n = 2 \implies \text{Interval} = 6$
    - $n > 2 \implies \text{Interval} = \lfloor \text{Interval}_{\text{cũ}} \times \text{EF}' \rfloor$

### 3.2. Xử lý Chấm điểm IELTS Writing & OCR AI
- **Xử lý Bất đồng bộ & Streaming:** Vì API Gemini chấm bài IELTS Writing Task 1 mất từ 3-8 giây, giao diện phải phản hồi ngay lập tức bằng cách chuyển 3D Avatar sang trạng thái `thinking` kèm Shimmer loading. Nếu có hỗ trợ Server-Sent Events (SSE) hoặc WebSockets, ưu tiên hiển thị kết quả chấm điểm theo dạng streaming từng phần (Band Score hiện trước -> Chi tiết lỗi ngữ pháp hiện sau).
- **Chuẩn hóa chuỗi JSON từ LLM:** Backend AI Gateway khi gọi Gemini phải ép mô hình trả về đúng định dạng JSON Schema cấu trúc rõ ràng (`response_mime_type: "application/json"`).

---

## 4. Quy chuẩn Định dạng Code & Linter (Style Guide)

- **Ngôn ngữ Dart/Flutter:**
  - Tuân thủ cấu trúc trong file `analysis_options.yaml` (dùng bộ rule `flutter_lints` hoặc `very_good_analysis`).
  - Luôn sử dụng từ khóa `const` cho các Widget và constructor bất biến để tối ưu hiệu năng rebuild UI.
  - Đặt tên biến/hàm theo chuẩn `lowerCamelCase`; tên Class/Enum/Typedef theo chuẩn `UpperCamelCase`; hằng số `lowerCamelCase` (hoặc `SCREAMING_SNAKE_CASE` cho constants toàn cục).
- **Ngôn ngữ TypeScript/Node.js (Backend):**
  - Tuân thủ ESLint và Prettier.
  - Sử dụng TypeScript với cờ strict mode (`"strict": true` trong `tsconfig.json`).
- **Chú thích & Tài liệu (Documentation integrity):**
  - Giữ nguyên các docstrings và comment giải thích kiến trúc hiện có khi sửa mã nguồn (theo guideline hiến pháp).
  - Thêm comment `///` (Doc comment) cho tất cả các public method trong `Domain Layer` và `Repositories`.
