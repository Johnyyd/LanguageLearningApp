-- =====================================================================
-- 🗄️ Microsoft SQL Server Database Initialization & Seeding Script
-- =====================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'LanguageAppDB')
BEGIN
    CREATE DATABASE LanguageAppDB;
    PRINT '✅ Database LanguageAppDB created successfully.';
END
ELSE
BEGIN
    PRINT 'ℹ️ Database LanguageAppDB already exists.';
END
GO

USE LanguageAppDB;
GO

-- 1. Table: users
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'users')
BEGIN
    CREATE TABLE users (
        id INT IDENTITY(1,1) PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        hashed_password VARCHAR(200) NOT NULL,
        created_at DATETIME DEFAULT GETDATE()
    );

    INSERT INTO users (username, email, hashed_password)
    VALUES 
    ('demo_student', 'student@languageapp.edu', '123456'),
    ('sensei_admin', 'admin@languageapp.edu', 'admin_secret_2026'),
    ('ielts_candidate', 'candidate@languageapp.edu', 'ielts80_2026');

    PRINT '✅ Table users created and seeded with demo accounts.';
END
GO

-- 2. Table: essay_submissions
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'essay_submissions')
BEGIN
    CREATE TABLE essay_submissions (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        prompt_id VARCHAR(50) NOT NULL,
        essay_text NVARCHAR(MAX) NOT NULL,
        overall_band FLOAT NOT NULL,
        json_report NVARCHAR(MAX) NOT NULL,
        submitted_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    INSERT INTO essay_submissions (user_id, prompt_id, essay_text, overall_band, json_report)
    VALUES 
    (3, 'task1_bar_chart_01', N'The bar chart compares car ownership levels per 1000 people across three European countries from 2000 to 2020. Overall, all three nations experienced a significant upward trend in car ownership.', 7.5, N'{"overall_band": 7.5, "task_achievement": 7.5, "coherence_cohesion": 7.0, "lexical_resource": 7.5, "grammatical_range": 8.0, "comment": "Bài viết có bố cục xuất sắc và sử dụng từ vựng học thuật đa dạng."}');

    PRINT '✅ Table essay_submissions created and seeded with sample IELTS reports.';
END
GO

-- 3. Table: chat_history
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'chat_history')
BEGIN
    CREATE TABLE chat_history (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        message NVARCHAR(MAX) NOT NULL,
        reply NVARCHAR(MAX) NOT NULL,
        emotion VARCHAR(50) DEFAULT 'idle',
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    INSERT INTO chat_history (user_id, message, reply, emotion)
    VALUES 
    (1, N'Trợ từ Wa và Ga trong tiếng Nhật khác nhau thế nào?', N'Trợ từ WA (は) dùng để nhấn mạnh CHỦ ĐỀ của câu, trong khi trợ từ GA (が) nhấn mạnh vào CHỦ NGỮ thực hiện hành động hoặc thông tin mới xuất hiện bạn nhé!', 'happy'),
    (1, N'Làm sao để viết mở bài Paraphrase cho biểu đồ IELTS?', N'Trong IELTS Writing Task 1, phần mở bài tốt nhất là Paraphrase lại đề bài bằng cách dùng đồng nghĩa! Đừng sao chép nguyên văn đề bài nhé!', 'explaining');

    PRINT '✅ Table chat_history created and seeded with sample Q&A logs.';
END
GO

PRINT '🎉 Microsoft SQL Server initialization & seeding completed.';
GO
