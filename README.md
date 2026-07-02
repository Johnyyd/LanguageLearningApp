# 🌟 Language Learning & IELTS AI Assistant (3D Avatar)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110.0-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![AI Engine](https://img.shields.io/badge/AI-Gemini%201.5%20Pro-4285F4?logo=google)](https://deepmind.google/technologies/gemini/)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%2FBLoC-purple)](https://pub.dev/packages/flutter_bloc)

Một ứng dụng di động hỗ trợ ôn luyện ngoại ngữ và luyện thi cao cấp (**Portfolio-Grade Application**) được phát triển dưới sự điều phối của đội ngũ AI Multi-Agent theo phương pháp **Spec-Driven Development (SDD)**:
- 🪐 **Antigravity** *(Điều phối viên & Thợ code UI)*
- 💻 **OpenCode** *(Thợ code chính Clean Architecture & BLoC)*
- ⚡ **Hermes** *(DevOps & Hạ tầng Docker/CI)*
- 🔍 **MiMo** *(QA Reviewer & Kiểm duyệt Hội tụ)*

---

## 🚀 Tính Năng Nổi Bật (Key Features)

### 1. 🎌 Tiếng Nhật N5 (Hiragana, Katakana, Kanji)
- **Thuật toán Spaced Repetition (SRS Anki / SuperMemo-2):** Tự động tính toán lịch ôn tập tối ưu theo mức độ ghi nhớ (Again, Hard, Good, Easy), lưu trữ ngoại tuyến bằng **Hive/Isar**.
- **Luyện viết nét chữ (Stroke Order Canvas):** Bảng vẽ cảm ứng tích hợp hướng dẫn chữ watermark, cho phép học viên dùng ngón tay/bút vẽ lại chữ Kana và tự động kiểm tra.
- **Thẻ Flashcard xoay 3D (3D Flip Card):** Hiệu ứng lật thẻ mượt mà hiển thị Hán tự/Romaji, nghĩa tiếng Việt và câu ví dụ kèm hệ thống chuỗi ngày học liên tục (Streak).
- **Hệ thống Quiz Trắc nghiệm (Multiple Choice Practice):** Bài kiểm tra 4 đáp án với hiệu ứng chúc mừng (Celebration), tính điểm trực quan và tự động tạo câu hỏi trắc nghiệm ngẫu nhiên giúp học viên củng cố từ vựng N5.

### 2. 📝 Luyện viết IELTS Writing Task 1 & AI Chấm điểm (Gemini 1.5 Pro)
- **Kho Đề thi Biểu đồ đa dạng:** Hỗ trợ Bar chart, Line graph, Pie chart, Table, và Process diagram.
- **Trình soạn thảo Kép (Dual Input Mode):**
  - **Gõ văn bản:** Bộ đếm từ thời gian thực, đồng hồ canh giờ 20 phút.
  - **Chụp ảnh bài viết tay (Camera OCR):** Sử dụng Google ML Kit OCR nhận diện chữ viết tay từ giấy chuyển thành văn bản số hóa để chỉnh sửa trước khi nộp.
- **Báo cáo Chấm điểm AI Đa chiều:**
  - **Dự đoán Band Score:** Chấm điểm tổng quát và chi tiết theo 4 tiêu chí (Task Achievement, Cohesion & Coherence, Lexical Resource, Grammatical Range & Accuracy).
  - **Phân tích Ngữ pháp:** Highlight chính xác dòng lỗi sai, cung cấp câu sửa chuẩn và giải thích chi tiết lý do sai bằng tiếng Việt.
  - **Nâng cấp Từ vựng (Academic Lexical Upgrade):** Gợi ý thay thế các cụm từ thông thường bằng từ vựng/collocation học thuật cao cấp kèm ví dụ ngữ cảnh.
  - **Shimmer Loading Skeleton:** Hiệu ứng tải trang mượt mà trong quá trình AI phân tích bài làm theo thời gian thực.

### 3. 🤖 Trợ lý 3D AI Tutor & Hỏi đáp Thời gian thực (Q&A)
- **Mô hình 3D Sensei AI:** Tích hợp mô hình 3D `.glb` trực quan tại phòng trò chuyện với khả năng xoay 360 độ và điều khiển góc nhìn.
- **Tương tác đa phương thức (Multimodal Voice & Speech):**
  - **Nhập giọng nói (Speech-to-Text):** Nút thu âm tích hợp ngay trên thanh chat cho phép học viên hỏi nhanh bằng giọng nói.
  - **Đọc câu trả lời (Text-to-Speech):** Hệ thống đọc câu trả lời bằng âm thanh vi-VN với chuyển động môi (Lip-syncing) đồng bộ.
- **Hoạt ảnh Đồng bộ (Dynamic Emotional Animations):**
  - `Thinking`: Gõ nhịp tay/suy nghĩ khi AI đang chấm bài, lắng nghe hoặc phân tích câu hỏi.
  - `Talking`: Cử động miệng đồng bộ theo thời gian thực khi hệ thống TTS phát âm thanh.
  - `Cheering`: Vỗ tay chúc mừng khi học viên làm đúng hoặc đạt điểm IELTS từ 6.5 trở lên.
- **Hệ thống Gợi ý Câu hỏi (Action Chips):** Tự động đề xuất các câu hỏi tiếp theo phù hợp với ngữ cảnh bài học.

---

## 🏛️ Kiến Trúc Hệ Thống & Quản Lý State (System Architecture)

Dự án tuân thủ mô hình **Clean Architecture** và chia thành 3 layers độc lập:
- `lib/domain/`: Contains Entities (`VocabItem`, `IeltsReport`, `ChatMessage`), SRS SuperMemo-2 calculation logic, Use Cases.
- `lib/data/`: Contains Local Hive DB Data Sources, Remote Dio API Adapters, Repository Implementations.
- `lib/presentation/`: Contains BLoC / Cubits (`VocabBloc`, `IeltsBloc`, `ChatBloc`), 3D Avatar Viewers, Custom UI Components.

```
LanguageLearningApp/
├── backend/                  # AI Gateway & Server (Python FastAPI + MS SQL Server)
│   ├── routers/              # Endpoints: auth, ielts, chat, vocab
│   ├── services/             # Gemini 1.5 Pro AI Engine integration
│   ├── sql_scripts/          # init_mssql.sql script tự động khởi tạo DB & seed data
│   ├── models.py             # SQLAlchemy schemas (pymssql / pyodbc)
│   └── Dockerfile            # DevOps containerization (FreeTDS & unixODBC)
├── mobile/                   # Flutter Mobile Application
│   ├── lib/
│   │   ├── core/             # AppTheme (Sakura/Navy), Dio ApiClient, Constants
│   │   ├── domain/           # Entities & SRS SM-2 Algorithm
│   │   ├── data/             # Hive Local Storage & Remote Repositories
│   │   └── presentation/     # BLoCs, 3D Avatar Viewer, Screens & Widgets
│   └── pubspec.yaml          # Flutter dependencies
├── docs/                     # SDD Portfolio Implementation Plan
└── .speckit/                 # SDD Governance Artifacts (constitution, specify, plan, tasks)
```

---

## 🛠️ Hướng Dẫn Cài Đặt & Chạy Thử (Quick Start)

### 1. Khởi động Môi trường Backend (Không cần cài đặt thủ công)
Để bạn hoặc các lập trình viên khác có thể clone code về máy mới và code ngay mà **không cần mất công cài đặt Python hay cấu hình môi trường**, chúng tôi đã chuẩn bị sẵn 3 phương án chuẩn hóa:

#### Phương án A: Sử dụng VS Code Dev Container (Khuyên dùng - Zero Install)
1. Cài đặt extension **Dev Containers** trong VS Code hoặc mở trên **GitHub Codespaces**.
2. Bấm `Reopen in Container`. Hệ thống sẽ tự động khởi tạo Docker container chứa sẵn Python 3.11, kết nối Microsoft SQL Server, cài đặt toàn bộ package và tự động copy `.env` từ `.env.example`.

#### Phương án B: Kịch bản One-Click Bootstrap (Chạy trực tiếp ngoài host)
Nếu bạn không dùng Docker, chỉ cần chạy 1 script tự động tạo `.venv`, cài package và cấu hình `.env`:
- **Linux / macOS:**
  ```bash
  bash backend/setup_env.sh
  ```
- **Windows (CMD / PowerShell):**
  ```cmd
  backend\setup_env.bat
  ```

#### Phương án C: Khởi chạy qua Docker Compose
Sử dụng Docker Compose (được thiết lập bởi `[Hermes]` tự động khởi chạy Microsoft SQL Server 2022, tạo Database và khởi tạo dữ liệu mẫu):
```bash
cd backend
docker-compose up --build -d
```
*Hệ thống sẽ tự động tạo 4 containers:*
- `language_app_sqlserver`: Container Microsoft SQL Server 2022 (Host Port 1111, Container Port 1433).
- `language_app_db_init`: Service tự động chạy script `/sql_scripts/init_mssql.sql` để tạo DB `LanguageAppDB` và seed dữ liệu.
- `language_app_redis`: Container Redis 7 Cache Engine (Host Port 1113, Container Port 6379).
- `language_app_ai_gateway`: FastAPI AI Gateway kết nối tới SQL Server và Redis (Port 1112).

API Gateway sẽ chạy tại `http://localhost:1112` (Tài liệu Swagger UI tại `/docs`).
> **Lưu ý Portfolio:** Backend đã tích hợp sẵn chế độ **Simulated Fallback Mode**, cho phép ứng dụng trả về nhận xét IELTS và câu trả lời AI thông minh ngay cả khi chưa cấu hình API Key của Gemini.

### 2. Khởi động Ứng dụng Di động Flutter
```bash
cd mobile
flutter pub get
flutter run
```
*Lưu ý khi chạy trên Android Emulator: Địa chỉ API mặc định trong `app_constants.dart` được thiết lập là `http://10.0.2.2:1112/api/v1`.*

---

## 🔒 Bảo Mật & Quy Chuẩn (Security & Compliance)
- **Bảo mật API Key:** Tuyệt đối không lưu trữ AI LLM Key ở Frontend client. Toàn bộ giao tiếp AI qua Backend AI Gateway proxy.
- **Bảo mật Token:** Sử dụng `flutter_secure_storage` mã hóa AES-GCM cho JWT access token.
- **Kiểm thử CI/CD:** Được tự động hóa qua GitHub Actions (`.github/workflows/ci.yml`).

---
*Dự án Portfolio thiết kế bởi Antigravity Multi-Agent Team (2026).*
