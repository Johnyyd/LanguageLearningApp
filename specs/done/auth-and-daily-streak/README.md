# Authentication & Daily Real-Date Streak — Rationale & Invariants

## Overview & Purpose
Hệ thống xác thực và theo dõi chuỗi ngày học liên tiếp (Streak) hoạt động dựa trên lịch ngày thực tế (`YYYY-MM-DD`). Người học đăng ký / đăng nhập tài khoản an toàn qua hệ thống backend FastAPI và theo dõi tiến độ chuỗi ngày liên tiếp của mình trực tiếp trên màn hình `DashboardScreen`.

## Core Rationale & Architectural Decisions

### 1. PBKDF2-SHA256 Password Hashing
Thay vì lưu trữ mật khẩu plaintext hoặc thuật toán hash đơn giản không muối, hệ thống sử dụng `passlib.context.CryptContext` với PBKDF2-SHA256 ([auth.py](file:///e:/GitHub/LanguageLearningApp/backend/routers/auth.py#L18-L30)). Điều này đảm bảo an toàn tuyệt đối trước tấn công từ điển và rainbow table mà không phụ thuộc vào thư viện nhị phân phức tạp trên các môi trường CI/CD khác nhau.

### 2. Calendar-Date Streak Calculation (`get_effective_streak`)
Streak được tính toán theo lịch thực tế từng ngày (`YYYY-MM-DD`) thay vì đếm giờ trôi qua ([auth.py](file:///e:/GitHub/LanguageLearningApp/backend/routers/auth.py#L38-L62)):
- **Gap = 0 (Hoạt động cùng ngày)**: Streak giữ nguyên, không tính lặp lại trong ngày.
- **Gap = 1 (Hoạt động liên tiếp hôm qua -> hôm nay)**: Streak tăng +1.
- **Gap > 1 (Bỏ lỡ >= 1 ngày học)**: Streak tự động đặt lại về 1 (khi có hoạt động mới) hoặc về 0 (khi kiểm tra trạng thái ngày hiện tại), phản ánh chính xác kỷ luật học tập.

## Key Code Pointers
- **Backend Auth & Streak API**: [auth.py](file:///e:/GitHub/LanguageLearningApp/backend/routers/auth.py)
- **Backend User Model**: [models.py](file:///e:/GitHub/LanguageLearningApp/backend/models.py#L11-L24)
- **Mobile Auth Modal**: [auth_modal.dart](file:///e:/GitHub/LanguageLearningApp/mobile/lib/presentation/widgets/auth/auth_modal.dart)
- **Mobile Real-Date Streak Card**: [dashboard_screen.dart](file:///e:/GitHub/LanguageLearningApp/mobile/lib/presentation/screens/dashboard_screen.dart#L240-L345)
