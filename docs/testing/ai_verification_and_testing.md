# 🧪 Hướng dẫn Kiểm thử, Nghiệm thu & Kiểm tra Yêu cầu cho AI (AI Verification & Testing Guide)

Tài liệu này cung cấp các tiêu chuẩn kiểm thử, quy trình xác minh tự động và danh sách nghiệm thu (Acceptance Criteria verification) để đảm bảo các đại lý AI (`OpenCode`, `MiMo`, `Antigravity`) luôn kiểm tra đúng và đủ yêu cầu trước khi hoàn tất bất kỳ tính năng nào trong ứng dụng **Language Learning & IELTS AI Assistant**.

> [!TIP]
> **Quy trình Kiểm định Chất lượng (Quality Assurance Workflow):** Không bao giờ coi một nhiệm vụ là "Hoàn thành" chỉ vì code có thể biên dịch (compile) thành công. Mọi tính năng phải vượt qua bộ kiểm tra 3 lớp: **Unit Test (Domain Logic)** $\rightarrow$ **Widget Test (UI/BLoC)** $\rightarrow$ **Integration/Driver Test (End-to-End Workflow)**.

---

## 1. Tiêu chí Chấp nhận Kỹ thuật Cốt lõi (Core Acceptance Criteria)

Trước khi bàn giao code, hệ thống phải thỏa mãn 3 tiêu chí vàng được quy định trong đặc tả của dự án (`specify.md`):

| Tiêu chí | Mục tiêu Đo lường | Phương pháp Kiểm tra bởi AI / QA |
| :--- | :--- | :--- |
| **1. Hiệu năng Khung hình (60 FPS)** | Ứng dụng chạy mượt mà ở tốc độ 60 FPS trên thiết bị di động, kể cả khi đang render mô hình 3D Avatar `.glb` và vẽ nét chữ trên Canvas. | Sử dụng Flutter DevTools hoặc tool `mcp_chrome-devtools_performance_start_trace` / lệnh đo FPS của Flutter Driver để đảm bảo không có frame nào bị drop vượt quá 16ms. |
| **2. Độ trễ Chấm điểm AI (< 10s)** | Thời gian phản hồi từ lúc gửi ảnh bài thi IELTS (OCR) hoặc văn bản đến lúc nhận báo cáo chấm điểm từ Gemini Gateway không quá 10 giây. | Đo thời gian thực thi (Latency benchmarking) trong các bài kiểm thử tích hợp API hoặc log `AppLogger.info(metadata: {'durationMs': ...})`. |
| **3. Bảo mật Mã hóa Dữ liệu** | 100% Token đăng nhập, Refresh Token và PII được lưu trong `flutter_secure_storage` (AES-GCM / Keychain), không rò rỉ trên ổ cứng thường. | Kiểm tra code review bằng `grep_search` và kiểm thử tự động xác nhận không đọc được token từ SharedPreferences không mã hóa. |

---

## 2. Chiến lược Kiểm thử 3 Lớp cho AI (Three-Tier Testing Strategy)

```mermaid
pyramid
    title Tháp Kiểm thử cho Language Learning App
    "Integration & UI Driver Tests (End-to-End Workflows)"
    "Widget & BLoC Tests (UI Components & State Transitions)"
    "Unit Tests (SRS Algorithm, Domain Use Cases, JSON Parsing)"
```

### 2.1. Lớp 1: Unit Test (Kiểm thử Đơn vị - Bắt buộc 80%+ Coverage cho Domain)
- **Tập trung vào:** Thuật toán Spaced Repetition (SRS SuperMemo-2), chuyển đổi DTO Models $\leftrightarrow$ Entities, validation dữ liệu đầu vào IELTS Writing.
- **Quy tắc viết Unit Test cho AI:**
  ```dart
  // Ví dụ kiểm thử thuật toán SRS N5
  import 'package:flutter_test/flutter_test.dart';
  import 'package:mobile/domain/usecases/calculate_srs_interval_usecase.dart';

  void main() {
    group('CalculateSrsIntervalUseCase - SuperMemo-2 Algorithm', () {
      late CalculateSrsIntervalUseCase useCase;

      setUp(() {
        useCase = CalculateSrsIntervalUseCase();
      });

      test('nhấn "Easy" (q=5) trên thẻ mới phải tăng E-Factor và đặt interval = 1 ngày', () {
        // Arrange
        final card = VocabCardEntity.initial(id: 'vocab_01');
        
        // Act
        final result = useCase.execute(card: card, quality: 5);

        // Assert
        expect(result.intervalDays, equals(1));
        expect(result.repetitionCount, equals(1));
        expect(result.easinessFactor, greaterThan(card.easinessFactor));
      });
    });
  }
  ```

### 2.2. Lớp 2: BLoC & Widget Test (Kiểm thử Giao diện & Trạng thái)
- Sử dụng gói `bloc_test` để kiểm tra các luồng phát ra State khi người dùng thao tác.
- **Kiểm thử Widget tiêu biểu:**
  - Xác nhận thẻ Flashcard lật mặt thành công khi nhận sự kiện chạm.
  - Xác nhận Bảng vẽ Kana vẽ được nét và đổi màu thành Xanh (`Zen Bamboo Green`) hoặc Đỏ (`Coral Red`) tùy thuộc vào kết quả trả về từ logic Stroke Order.
  - Xác nhận mô hình 3D Avatar hiển thị đúng animation (`idle`, `thinking`, `talking`) khi BLoC chuyển state.

### 2.3. Lớp 3: Integration & Flutter Driver Test (Kiểm thử Luồng tự động)
- Các đại lý AI được quyền sử dụng công cụ MCP `dart-mcp-server` (đặc biệt là các tool `widget_inspector`, `flutter_driver_command`) để tự động tương tác và kiểm chứng ứng dụng đang chạy.
- **Các luồng End-to-End (E2E) cần kiểm tra định kỳ:**
  1. **Luồng E2E 1:** Mở app $\rightarrow$ Đăng nhập thành công $\rightarrow$ Vào gói từ vựng N5 Bài 1 $\rightarrow$ Lật 3 thẻ Flashcard $\rightarrow$ Vẽ đúng 1 chữ Kana $\rightarrow$ Kiểm tra điểm SRS được lưu cục bộ.
  2. **Luồng E2E 2:** Vào phòng thi IELTS Writing $\rightarrow$ Nhập đoạn văn bản mẫu 150 từ $\rightarrow$ Bấm Nộp bài $\rightarrow$ Kiểm tra Avatar 3D chuyển sang trạng thái `thinking` $\rightarrow$ Nhận báo cáo Band Score hiển thị đúng biểu đồ Radar.

---

## 3. Quy trình Hội tụ & Kiểm duyệt Chất lượng cho MiMo (QA Review Checklist)

Đại lý kiểm thử và chất lượng (`MiMo`) khi thực hiện nhiệm vụ review mã nguồn theo chuẩn `/speckit.converge` bắt buộc phải rà soát bảng kiểm sau:

### 3.1. Rà soát Mã nguồn & Kiến trúc (Code & Architecture QA)
- [ ] **Clean Architecture Compliant:** Không có widget UI nào import trực tiếp gói database (`hive`, `isar`) hoặc HTTP client (`dio`).
- [ ] **No Unhandled Failures:** Tất cả các method trong Repository đều trả về `Either<Failure, T>`, không để lọt exception làm crash app.
- [ ] **GitNexus Safe Check:** Đã chạy lệnh `gitnexus_detect_changes()` và xác nhận không sửa nhầm các symbol ngoài phạm vi yêu cầu của task.

### 3.2. Rà soát UI/UX & Tương tác 3D Avatar (Visual & Animation QA)
- [ ] **Shimmer & Loading States:** Không có màn hình nào bị trắng bóc hoặc bị đơ khi đang chờ gọi API Gemini; Shimmer loading phải xuất hiện mượt mà.
- [ ] **3D Memory Leak Check:** Khi thoát màn hình Chat có 3D Avatar, bộ nhớ RAM/GPU phải được giải phóng đúng cách (dispose `model_viewer_plus`/controller).
- [ ] **Responsive Layout:** Kiểm tra trên màn hình nhỏ không có widget nào bị lỗi overflow dải màu vàng đen.

### 3.3. Rà soát Bảo mật & Logging (Security & Logging QA)
- [ ] **Zero API Keys in Client:** Chạy `grep_search` xác nhận tuyệt đối không có API Key của LLM hay Cloud nằm trong mã nguồn Dart.
- [ ] **Structured Log Verification:** Xác nhận khi chạy các luồng chính, log in ra console tuân thủ định dạng JSON/Chuẩn có `correlationId`, `level`, và `tag`.
