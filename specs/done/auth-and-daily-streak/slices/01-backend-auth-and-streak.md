# Slice 01: Backend Auth & Real-Date Streak Engine

## Contract Unlocked
Cho phép người dùng tạo tài khoản mới (Register), đăng nhập an toàn (Login với mật khẩu được băm hash SHA-256/bcrypt), và gọi API ghi nhận hoạt động học tập (`POST /api/v1/auth/activity`) để tính toán chính xác số ngày học liên tục (streak) theo ngày thực tế.

## API Seams & Data Shape
1. **User Model (`models.py`)**:
   - `id`: Integer primary key
   - `username`: String(50), unique
   - `email`: String(100), unique
   - `hashed_password`: String(200)
   - `full_name`: String(100), nullable
   - `streak_count`: Integer (default=0)
   - `last_activity_date`: String(20), nullable (`YYYY-MM-DD`)
2. **Endpoints (`routers/auth.py`)**:
   - `POST /api/v1/auth/register`
     - Request body: `{ "username": "...", "email": "...", "password": "...", "full_name": "..." }`
     - Response: `{ "access_token": "...", "token_type": "bearer", "username": "...", "user_id": 1, "streak_count": 0, "last_activity_date": null }`
   - `POST /api/v1/auth/login`
     - Request body: `{ "username": "...", "password": "..." }`
     - Response: `{ "access_token": "...", "token_type": "bearer", "username": "...", "user_id": 1, "streak_count": ..., "last_activity_date": "..." }`
   - `GET /api/v1/auth/me`
     - Response: `{ "user_id": ..., "username": "...", "email": "...", "streak_count": ..., "last_activity_date": "..." }`
   - `POST /api/v1/auth/activity`
     - Request body: `{ "username": "...", "activity_date": "YYYY-MM-DD" }` (or auth token sub)
     - Logic:
       - Nếu `last_activity_date == activity_date`: giữ nguyên `streak_count`.
       - Nếu `activity_date` là ngày kế tiếp ngay sau `last_activity_date` (`diff == 1 day`): `streak_count += 1`.
       - Nếu `activity_date` cách `last_activity_date` > 1 ngày (hoặc `last_activity_date` null): reset `streak_count = 1`.
       - Cập nhật `last_activity_date = activity_date`.

## Verification Gates
- Kiểm tra trực tiếp bằng Python script test logic streak tăng, giữ nguyên, và reset khi ngắt chuỗi.
