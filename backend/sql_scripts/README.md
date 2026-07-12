# 🗄️ Database Architecture, Seeding & Backup Guide (LanguageAppDB)

Tài liệu hướng dẫn cấu trúc cơ sở dữ liệu **LanguageAppDB** (Microsoft SQL Server / SQLite / PostgreSQL), dữ liệu mẫu làm giàu (Rich Seeding) và quy trình Backup/Restore chuẩn Enterprise cho ứng dụng **Language Learning & IELTS AI Gateway**.

---

## 1. Kiến Trúc Bảng & Khả Năng Mở Rộng (Extensible Schema & Constraints)

Hệ thống được thiết kế theo chuẩn chuẩn hóa 3NF với đầy đủ khóa chính (`PRIMARY KEY`), khóa ngoại (`FOREIGN KEY ON DELETE CASCADE`), ràng buộc kiểm tra (`CHECK CONSTRAINTS`), ràng buộc duy nhất (`UNIQUE INDEXES`) và chỉ mục truy vấn (`NONCLUSTERED INDEXES`):

| Tên Bảng | Mục Đích | Ràng Buộc Quan Trọng |
| :--- | :--- | :--- |
| **`users`** | Tài khoản người dùng & Role-based Access Control | `UQ_users_username`, `UQ_users_email`, `CHK_users_role`, `CHK_users_streak` |
| **`course_modules`** | Danh mục khóa học mở rộng (N5 Vocab, Grammar, IELTS Task 1/2) | `UQ_course_modules_code`, `CHK_course_modules_category` |
| **`lessons`** | Bài học chi tiết thuộc từng Module | `FK_lessons_module`, `UQ_lessons_module_order` |
| **`user_lesson_progress`** | Tiến độ học tập độc lập từng học viên trên từng bài học | `FK_progress_user`, `FK_progress_lesson`, `UQ_user_lesson_progress` |
| **`user_streaks_log`** | Nhật ký điểm danh & duy trì chuỗi Streak hằng ngày | `FK_streak_log_user`, `UQ_user_activity_date` |
| **`essay_submissions`** | Bài viết IELTS Task 1/Task 2 & báo cáo chấm điểm JSON Gemini AI | `FK_essay_user`, `CHK_essay_band (0.0 - 9.0)` |
| **`chat_history`** | Nhật ký hội thoại AI 3D Tutor với phân loại cảm xúc | `FK_chat_user` |
| **`srs_flashcards_progress`** | Học từ vựng Spaced Repetition Leitner Box (1-5) | `FK_srs_user`, `CHK_srs_box_level (1-5)`, `UQ_srs_user_kanji` |

---

## 2. Dữ Liệu Mẫu Phong Phú (Rich Seed Data)

Script `init_mssql.sql` tự động chèn dữ liệu mẫu thực tế, đầy đủ ngữ cảnh để phục vụ phát triển & Demo:

### 👤 Tài Khoản Mẫu (Seeded Users):
1. **Học viên mẫu (`demo_student`)**
   - Email: `student@languageapp.edu` | Mật khẩu: `123456`
   - Role: `student` | Streak: `5 ngày` | Mục tiêu: `JLPT N5`
2. **Quản trị viên (`sensei_admin`)**
   - Email: `admin@languageapp.edu` | Mật khẩu: `admin_secret_2026`
   - Role: `admin` | Streak: `30 ngày`
3. **Thí sinh IELTS (`ielts_candidate`)**
   - Email: `candidate@languageapp.edu` | Mật khẩu: `ielts80_2026`
   - Role: `premium` | Streak: `14 ngày` | Mục tiêu: `IELTS Band 8.0`

### 📚 Khóa Học & Bài Học Mẫu (Course Modules & Lessons):
- 6 Module chính: `japanese_n5_vocab`, `japanese_n5_grammar`, `japanese_n5_dialogue`, `japanese_n5_mock_exam`, `ielts_writing_task1`, `ielts_writing_task2`.
- 11 Bài học chuẩn được kết nối sẵn với Module.
- Lịch sử duy trì Streak 5 ngày liên tục và báo cáo chấm điểm IELTS chi tiết.

---

## 3. Hướng Dẫn Backup & Restore (Enterprise Backup/Restore)

### 💾 A. Tạo Bản Sao Lưu (Backup):
Sử dụng Stored Procedure `sp_BackupLanguageAppDB` đã được khởi tạo sẵn trong DB:
```sql
USE LanguageAppDB;
GO
-- Backup toàn phần (Full Backup)
EXEC dbo.sp_BackupLanguageAppDB @BackupDirectory = N'/var/opt/mssql/backup', @BackupType = 'FULL';
```

Hoặc chạy từ Terminal Docker:
```bash
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'SuperStrong!Pass2026' -C -Q "EXEC LanguageAppDB.dbo.sp_BackupLanguageAppDB @BackupDirectory = N'/var/opt/mssql/backup', @BackupType = 'FULL';"
```

### ♻️ B. Phục Hồi Dữ Liệu (Restore):
Chạy lệnh SQL từ database `master`:
```sql
USE master;
GO
ALTER DATABASE LanguageAppDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE LanguageAppDB
FROM DISK = '/var/opt/mssql/backup/LanguageAppDB_FULL_YYYYMMDD_HHMMSS.bak'
WITH REPLACE, STATS = 10;
ALTER DATABASE LanguageAppDB SET MULTI_USER;
GO
```
