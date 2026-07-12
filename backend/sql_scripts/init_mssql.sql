-- ========================================================================================
-- 🗄️ Microsoft SQL Server Enterprise Database Initialization & Rich Data Seeding Script
-- System: Language Learning & IELTS AI Gateway (Antigravity SDD Platform)
-- Version: 2.0.0 (Extensible Architecture + Full Constraints + Backup/Restore Procedures)
-- ========================================================================================

SET NOCOUNT ON;
GO

-- ----------------------------------------------------------------------------------------
-- 1. DATABASE CREATION & RECOVERY CONFIGURATION
-- ----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'LanguageAppDB')
BEGIN
    CREATE DATABASE LanguageAppDB;
    PRINT '✅ [Database] LanguageAppDB created successfully.';
END
ELSE
BEGIN
    PRINT 'ℹ️ [Database] LanguageAppDB already exists. Using existing database.';
END
GO

USE LanguageAppDB;
GO

-- ----------------------------------------------------------------------------------------
-- 2. TABLE DDL: users
-- Core user accounts with role-based access control, streak persistence, and constraints
-- ----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'users')
BEGIN
    CREATE TABLE users (
        id INT IDENTITY(1,1) PRIMARY KEY,
        username VARCHAR(50) NOT NULL,
        email VARCHAR(100) NOT NULL,
        hashed_password VARCHAR(200) NOT NULL,
        full_name NVARCHAR(100) NULL,
        role VARCHAR(20) NOT NULL DEFAULT 'student',
        streak_count INT NOT NULL DEFAULT 0,
        last_activity_date VARCHAR(20) NULL,
        avatar_url NVARCHAR(255) NULL,
        target_exam VARCHAR(50) DEFAULT 'JLPT N5',
        target_score VARCHAR(20) DEFAULT '180/180',
        is_active BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT UQ_users_username UNIQUE (username),
        CONSTRAINT UQ_users_email UNIQUE (email),
        CONSTRAINT CHK_users_role CHECK (role IN ('student', 'tutor', 'admin', 'premium')),
        CONSTRAINT CHK_users_streak CHECK (streak_count >= 0)
    );

    CREATE NONCLUSTERED INDEX IX_users_username ON users(username);
    CREATE NONCLUSTERED INDEX IX_users_email ON users(email);
    CREATE NONCLUSTERED INDEX IX_users_role ON users(role);

    PRINT '✅ [Table] users created with unique indexes & check constraints.';
END
ELSE
BEGIN
    -- Backward compatibility alter for existing tables
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('users') AND name = 'full_name')
        ALTER TABLE users ADD full_name NVARCHAR(100) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('users') AND name = 'streak_count')
        ALTER TABLE users ADD streak_count INT NOT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('users') AND name = 'last_activity_date')
        ALTER TABLE users ADD last_activity_date VARCHAR(20) NULL;
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('users') AND name = 'role')
        ALTER TABLE users ADD role VARCHAR(20) NOT NULL DEFAULT 'student';
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('users') AND name = 'target_exam')
        ALTER TABLE users ADD target_exam VARCHAR(50) DEFAULT 'JLPT N5';
END
GO

-- ----------------------------------------------------------------------------------------
-- 3. TABLE DDL: course_modules
-- Extensible course catalog (Japanese N5 Vocab, Grammar, Dialogues, IELTS Writing, etc.)
-- ----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'course_modules')
BEGIN
    CREATE TABLE course_modules (
        id INT IDENTITY(1,1) PRIMARY KEY,
        module_code VARCHAR(50) NOT NULL,
        module_name NVARCHAR(100) NOT NULL,
        category VARCHAR(30) NOT NULL,
        level_name VARCHAR(20) NOT NULL,
        description NVARCHAR(255) NULL,
        icon_name VARCHAR(50) NULL,
        is_active BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT UQ_course_modules_code UNIQUE (module_code),
        CONSTRAINT CHK_course_modules_category CHECK (category IN ('japanese', 'ielts', 'general'))
    );

    CREATE NONCLUSTERED INDEX IX_course_modules_category ON course_modules(category);
    PRINT '✅ [Table] course_modules created.';
END
GO

-- ----------------------------------------------------------------------------------------
-- 4. TABLE DDL: lessons
-- Individual lessons within course modules
-- ----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'lessons')
BEGIN
    CREATE TABLE lessons (
        id INT IDENTITY(1,1) PRIMARY KEY,
        module_id INT NOT NULL,
        lesson_order INT NOT NULL,
        title NVARCHAR(150) NOT NULL,
        summary NVARCHAR(500) NULL,
        xp_reward INT NOT NULL DEFAULT 20,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT FK_lessons_module FOREIGN KEY (module_id) REFERENCES course_modules(id) ON DELETE CASCADE,
        CONSTRAINT CHK_lessons_order CHECK (lesson_order > 0),
        CONSTRAINT UQ_lessons_module_order UNIQUE (module_id, lesson_order)
    );

    CREATE NONCLUSTERED INDEX IX_lessons_module_id ON lessons(module_id);
    PRINT '✅ [Table] lessons created.';
END
GO

-- ----------------------------------------------------------------------------------------
-- 5. TABLE DDL: user_lesson_progress
-- Precise completion state per user per lesson (prevents cross-lesson completion bugs)
-- ----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'user_lesson_progress')
BEGIN
    CREATE TABLE user_lesson_progress (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        lesson_id INT NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'in_progress',
        score FLOAT NULL,
        completed_at DATETIME2 NULL,
        last_accessed_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT FK_progress_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        CONSTRAINT FK_progress_lesson FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
        CONSTRAINT CHK_progress_status CHECK (status IN ('not_started', 'in_progress', 'completed')),
        CONSTRAINT CHK_progress_score CHECK (score IS NULL OR (score >= 0.0 AND score <= 100.0)),
        CONSTRAINT UQ_user_lesson_progress UNIQUE (user_id, lesson_id)
    );

    CREATE NONCLUSTERED INDEX IX_progress_user_id ON user_lesson_progress(user_id);
    CREATE NONCLUSTERED INDEX IX_progress_lesson_id ON user_lesson_progress(lesson_id);
    PRINT '✅ [Table] user_lesson_progress created.';
END
GO

-- ----------------------------------------------------------------------------------------
-- 6. TABLE DDL: user_streaks_log
-- Audit trail of daily user learning activity for verifiable streak analytics
-- ----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'user_streaks_log')
BEGIN
    CREATE TABLE user_streaks_log (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        activity_date DATE NOT NULL,
        activity_type VARCHAR(50) NOT NULL DEFAULT 'login',
        xp_earned INT NOT NULL DEFAULT 10,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT FK_streak_log_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        CONSTRAINT UQ_user_activity_date UNIQUE (user_id, activity_date, activity_type)
    );

    CREATE NONCLUSTERED INDEX IX_streak_log_user_date ON user_streaks_log(user_id, activity_date);
    PRINT '✅ [Table] user_streaks_log created.';
END
GO

-- ----------------------------------------------------------------------------------------
-- 7. TABLE DDL: essay_submissions
-- IELTS Writing Task 1 & Task 2 submissions with detailed AI JSON evaluation reports
-- ----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'essay_submissions')
BEGIN
    CREATE TABLE essay_submissions (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        prompt_id VARCHAR(50) NOT NULL,
        prompt_title NVARCHAR(200) NULL,
        essay_text NVARCHAR(MAX) NOT NULL,
        word_count INT NOT NULL DEFAULT 0,
        overall_band FLOAT NOT NULL,
        task_achievement FLOAT NULL,
        coherence_cohesion FLOAT NULL,
        lexical_resource FLOAT NULL,
        grammatical_range FLOAT NULL,
        json_report NVARCHAR(MAX) NOT NULL,
        submitted_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT FK_essay_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        CONSTRAINT CHK_essay_band CHECK (overall_band >= 0.0 AND overall_band <= 9.0)
    );

    CREATE NONCLUSTERED INDEX IX_essay_user_id ON essay_submissions(user_id);
    PRINT '✅ [Table] essay_submissions created.';
END
GO

-- ----------------------------------------------------------------------------------------
-- 8. TABLE DDL: chat_history
-- 3D AI Tutor dialogue log with emotion tags and speech synthesis references
-- ----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'chat_history')
BEGIN
    CREATE TABLE chat_history (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        session_id VARCHAR(100) NULL,
        speaker_id VARCHAR(50) DEFAULT 'sensei_va_01',
        message NVARCHAR(MAX) NOT NULL,
        reply NVARCHAR(MAX) NOT NULL,
        emotion VARCHAR(50) DEFAULT 'idle',
        audio_url NVARCHAR(255) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT FK_chat_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX IX_chat_user_id ON chat_history(user_id);
    PRINT '✅ [Table] chat_history created.';
END
GO

-- ----------------------------------------------------------------------------------------
-- 9. TABLE DDL: srs_flashcards_progress
-- Leitner Spaced Repetition System (SRS) vocabulary tracking per user
-- ----------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'srs_flashcards_progress')
BEGIN
    CREATE TABLE srs_flashcards_progress (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        word_kanji NVARCHAR(50) NOT NULL,
        box_level INT NOT NULL DEFAULT 1,
        next_review_date DATE NOT NULL,
        review_count INT NOT NULL DEFAULT 0,
        last_reviewed_at DATETIME2 NULL,

        CONSTRAINT FK_srs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        CONSTRAINT CHK_srs_box_level CHECK (box_level BETWEEN 1 AND 5),
        CONSTRAINT UQ_srs_user_kanji UNIQUE (user_id, word_kanji)
    );

    CREATE NONCLUSTERED INDEX IX_srs_user_date ON srs_flashcards_progress(user_id, next_review_date);
    PRINT '✅ [Table] srs_flashcards_progress created.';
END
GO

-- ========================================================================================
-- 10. RICH DATA SEEDING (LÀM GIÀU DỮ LIỆU PHONG PHÚ)
-- ========================================================================================

-- A. Seeding Users (6 Tài khoản đa dạng: Học viên N5, IELTS Candidate, Admin, Premium Learner)
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'demo_student')
BEGIN
    INSERT INTO users (username, email, hashed_password, full_name, role, streak_count, last_activity_date, target_exam, target_score)
    VALUES 
    ('demo_student', 'student@languageapp.edu', '123456', N'Nguyễn Văn Học Viên', 'student', 5, CONVERT(VARCHAR(10), GETDATE(), 120), 'JLPT N5', '180/180'),
    ('sensei_admin', 'admin@languageapp.edu', 'admin_secret_2026', N'Yamada Sensei Admin', 'admin', 30, CONVERT(VARCHAR(10), GETDATE(), 120), 'ALL', 'MAX'),
    ('ielts_candidate', 'candidate@languageapp.edu', 'ielts80_2026', N'Trần Thị Mai IELTS', 'premium', 14, CONVERT(VARCHAR(10), GETDATE(), 120), 'IELTS Academic', '8.0/9.0'),
    ('minh_duc_n5', 'minhduc@languageapp.edu', '123456', N'Lê Minh Đức', 'student', 3, CONVERT(VARCHAR(10), DATEADD(day, -1, GETDATE()), 120), 'JLPT N5', '160/180'),
    ('sakura_learner', 'sakura@languageapp.edu', '123456', N'Sakura Takahashi', 'premium', 7, CONVERT(VARCHAR(10), GETDATE(), 120), 'JLPT N4', '170/180'),
    ('lan_anh_ielts', 'lananh@languageapp.edu', '123456', N'Phạm Lan Anh', 'student', 1, CONVERT(VARCHAR(10), GETDATE(), 120), 'IELTS Academic', '7.0/9.0');

    PRINT '✅ [Seed] 6 rich user accounts inserted.';
END
GO

-- B. Seeding Course Modules (6 Khóa học Nhật ngữ JLPT N5 & IELTS Academic)
IF NOT EXISTS (SELECT 1 FROM course_modules WHERE module_code = 'japanese_n5_vocab')
BEGIN
    INSERT INTO course_modules (module_code, module_name, category, level_name, description, icon_name)
    VALUES
    ('japanese_n5_vocab', N'Từ vựng JLPT N5 Nền Tảng', 'japanese', 'N5', N'Ngân hàng từ vựng thiết yếu cho người mới bắt đầu học tiếng Nhật JLPT N5', 'vocab_icon'),
    ('japanese_n5_grammar', N'Ngữ pháp JLPT N5 Trọng Tâm', 'japanese', 'N5', N'Cấu trúc mẫu câu, trợ từ Wa/Ga/Ni/De và cách chia thể động từ N5', 'grammar_icon'),
    ('japanese_n5_dialogue', N'Hội thoại Phản xạ Giao tiếp N5', 'japanese', 'N5', N'Thực hành nhập vai hội thoại tình huống thực tế với Sensei AI 3D', 'dialogue_icon'),
    ('japanese_n5_mock_exam', N'Đề thi thử chuẩn JLPT N5', 'japanese', 'N5', N'Thi thử cấu trúc chuẩn thi JLPT có tính giờ và chấm điểm tự động', 'exam_icon'),
    ('ielts_writing_task1', N'IELTS Writing Task 1 Academic', 'ielts', 'Band 7+', N'Luyện viết phân tích biểu đồ Line Chart, Bar Chart, Pie Chart & Process', 'chart_icon'),
    ('ielts_writing_task2', N'IELTS Writing Task 2 Essay', 'ielts', 'Band 7+', N'Luyện viết nghị luận xã hội Opinion, Discussion & Problem-Solution', 'essay_icon');

    PRINT '✅ [Seed] 6 Course Modules inserted.';
END
GO

-- C. Seeding Lessons (Danh sách Bài học chi tiết cho từng Module)
DECLARE @ModVocab INT = (SELECT id FROM course_modules WHERE module_code = 'japanese_n5_vocab');
DECLARE @ModGrammar INT = (SELECT id FROM course_modules WHERE module_code = 'japanese_n5_grammar');
DECLARE @ModIelts1 INT = (SELECT id FROM course_modules WHERE module_code = 'ielts_writing_task1');

IF NOT EXISTS (SELECT 1 FROM lessons WHERE module_id = @ModVocab AND lesson_order = 1)
BEGIN
    INSERT INTO lessons (module_id, lesson_order, title, summary, xp_reward)
    VALUES
    (@ModVocab, 1, N'Bài 1: Chào hỏi & Tự giới thiệu (Lời chào Nhật Bản)', N'Học cách chào hỏi cơ bản Ohayou, Konnichiwa và giới thiệu tên tuổi nghề nghiệp', 20),
    (@ModVocab, 2, N'Bài 2: Gia đình & Người thân (Kazoku)', N'Từ vựng về thành viên gia đình mình và gia đình người khác theo văn hóa Nhật', 25),
    (@ModVocab, 3, N'Bài 3: Thời gian, Ngày tháng & Giờ giấc', N'Cách đọc số đếm, thứ ngày tháng và cách nói thời gian trong tiếng Nhật', 25),
    (@ModVocab, 4, N'Bài 4: Mua sắm & Tiền tệ tại Konbini', N'Các mẫu câu hỏi giá tiền Ikura desu ka và tên đồ dùng hàng ngày', 30),
    (@ModVocab, 5, N'Bài 5: Phương tiện giao thông & Đường đi', N'Từ vựng tàu điện Densha, xe buýt Basu và chỉ đường cơ bản', 30),

    (@ModGrammar, 1, N'Bài 1: Trợ từ chủ đề WA (は) và trợ từ sở hữu NO (の)', N'Phân biệt cấu trúc danh từ A wa B desu và sở hữu A no B', 25),
    (@ModGrammar, 2, N'Bài 2: Động từ thể lịch sự MASU (ます) & câu hỏi KA (か)', N'Cách chia hiện tại, quá khứ khẳng định và phủ định của động từ N5', 30),
    (@ModGrammar, 3, N'Bài 3: Trợ từ địa điểm DE (で) và NI (に)', N'Phân biệt nơi diễn ra hành động De và nơi tồn tại/đích đến Ni', 30),

    (@ModIelts1, 1, N'Task 1: Line Chart - Xu hướng số liệu động (Dynamic Trends)', N'Cấu trúc Paraphrase đề bài, Overview và từ vựng miêu tả tăng giảm mạnh nhẹ', 40),
    (@ModIelts1, 2, N'Task 1: Bar Chart - So sánh số liệu tĩnh (Static Comparisons)', N'Cách nhóm số liệu, so sánh cao nhất/thấp nhất và sử dụng từ nối đối lập', 40),
    (@ModIelts1, 3, N'Task 1: Process Diagram - Quy trình sản xuất & Tự nhiên', N'Sử dụng câu bị động (Passive Voice) và từ nối tuần tự bước trong quy trình', 45);

    PRINT '✅ [Seed] 11 structured Lessons inserted.';
END
GO

-- D. Seeding User Lesson Progress (Dữ liệu tiến độ chuẩn để tránh lỗi hoàn thành chéo bài học)
DECLARE @DemoUserId INT = (SELECT id FROM users WHERE username = 'demo_student');
DECLARE @L1 INT = (SELECT l.id FROM lessons l JOIN course_modules m ON l.module_id = m.id WHERE m.module_code = 'japanese_n5_vocab' AND l.lesson_order = 1);
DECLARE @L2 INT = (SELECT l.id FROM lessons l JOIN course_modules m ON l.module_id = m.id WHERE m.module_code = 'japanese_n5_vocab' AND l.lesson_order = 2);
DECLARE @L3 INT = (SELECT l.id FROM lessons l JOIN course_modules m ON l.module_id = m.id WHERE m.module_code = 'japanese_n5_vocab' AND l.lesson_order = 3);

IF NOT EXISTS (SELECT 1 FROM user_lesson_progress WHERE user_id = @DemoUserId AND lesson_id = @L1) AND @DemoUserId IS NOT NULL AND @L1 IS NOT NULL
BEGIN
    INSERT INTO user_lesson_progress (user_id, lesson_id, status, score, completed_at)
    VALUES
    (@DemoUserId, @L1, 'completed', 100.0, GETDATE()),
    (@DemoUserId, @L2, 'completed', 90.0, GETDATE()),
    (@DemoUserId, @L3, 'in_progress', 65.0, NULL);

    PRINT '✅ [Seed] User lesson progress entries inserted.';
END
GO

-- E. Seeding User Streaks Log (Lịch sử duy trì chuỗi học tập thực tế)
DECLARE @DemoUserId2 INT = (SELECT id FROM users WHERE username = 'demo_student');
IF NOT EXISTS (SELECT 1 FROM user_streaks_log WHERE user_id = @DemoUserId2 AND activity_date = CONVERT(DATE, GETDATE())) AND @DemoUserId2 IS NOT NULL
BEGIN
    INSERT INTO user_streaks_log (user_id, activity_date, activity_type, xp_earned)
    VALUES
    (@DemoUserId2, DATEADD(day, -4, CONVERT(DATE, GETDATE())), 'vocab_practice', 20),
    (@DemoUserId2, DATEADD(day, -3, CONVERT(DATE, GETDATE())), 'grammar_quiz', 25),
    (@DemoUserId2, DATEADD(day, -2, CONVERT(DATE, GETDATE())), 'roleplay_dialogue', 30),
    (@DemoUserId2, DATEADD(day, -1, CONVERT(DATE, GETDATE())), 'ielts_writing', 40),
    (@DemoUserId2, CONVERT(DATE, GETDATE()), 'daily_login', 10);

    PRINT '✅ [Seed] 5-day continuous streak audit log inserted.';
END
GO

-- F. Seeding IELTS Essay Submissions (Đánh giá chuyên sâu với trọn bộ chi tiết chấm điểm)
DECLARE @IeltsUserId INT = (SELECT id FROM users WHERE username = 'ielts_candidate');
IF NOT EXISTS (SELECT 1 FROM essay_submissions WHERE prompt_id = 'task1_bar_chart_01') AND @IeltsUserId IS NOT NULL
BEGIN
    INSERT INTO essay_submissions (user_id, prompt_id, prompt_title, essay_text, word_count, overall_band, task_achievement, coherence_cohesion, lexical_resource, grammatical_range, json_report)
    VALUES
    (
        @IeltsUserId,
        'task1_bar_chart_01',
        N'Car Ownership Trends in European Countries (2000-2020)',
        N'The bar chart compares car ownership levels per 1000 people across three European countries from 2000 to 2020. Overall, all three nations experienced a significant upward trend in car ownership, with Germany maintaining the highest proportion throughout the twenty-year period. Specifically, car ownership in France rose steadily from 450 to 620 cars per 1000 inhabitants.',
        168,
        7.5,
        7.5,
        7.5,
        7.5,
        7.5,
        N'{"overall_band": 7.5, "task_achievement": 7.5, "coherence_cohesion": 7.5, "lexical_resource": 7.5, "grammatical_range": 7.5, "feedback_summary": "Bài viết có bố cục xuất sắc, nêu bật được xu hướng chính và có sự so sánh số liệu rất chính xác.", "strengths": ["Paraphrase đề bài tự nhiên", "Sử dụng từ nối chuyển ý uyển chuyển"], "improvements": ["Nên đa dạng cấu trúc bị động hơn"]}'
    ),
    (
        @IeltsUserId,
        'task2_tech_education_01',
        N'Technology in Classroom vs Traditional Teachers',
        N'In modern society, artificial intelligence and online platforms have transformed education. While some argue that automated teachers could replace human instructors entirely, I firmly believe that human educators play an irreplaceable role in emotional support, ethics, and interactive guidance that technology can only supplement rather than replace.',
        254,
        8.0,
        8.0,
        8.0,
        8.0,
        8.0,
        N'{"overall_band": 8.0, "task_achievement": 8.0, "coherence_cohesion": 8.0, "lexical_resource": 8.0, "grammatical_range": 8.0, "feedback_summary": "Lập luận sâu sắc, vốn từ vựng học thuật cao siêu cấp C1/C2.", "strengths": ["Luận điểm rõ ràng", "Từ vựng chính xác như irreplaceable, supplement"], "improvements": []}'
    );

    PRINT '✅ [Seed] IELTS essay submissions inserted.';
END
GO

-- G. Seeding 3D AI Tutor Chat History (Hội thoại phong phú Nhật ngữ & IELTS)
DECLARE @DemoUserId3 INT = (SELECT id FROM users WHERE username = 'demo_student');
IF NOT EXISTS (SELECT 1 FROM chat_history WHERE message LIKE N'%Trợ từ Wa và Ga%') AND @DemoUserId3 IS NOT NULL
BEGIN
    INSERT INTO chat_history (user_id, speaker_id, message, reply, emotion)
    VALUES
    (
        @DemoUserId3,
        'sensei_va_01',
        N'Sensei ơi, Trợ từ Wa (は) và Ga (が) trong tiếng Nhật khác nhau thế nào ạ?',
        N'Chào em! Trợ từ WA (は) dùng để nhấn mạnh CHỦ ĐỀ của câu (thông tin đã biết), còn trợ từ GA (が) nhấn mạnh vào CHỦ NGỮ thực hiện hành động hoặc thông tin mới xuất hiện lần đầu em nhé! Ví dụ: Watashi wa gakusei desu (Tôi là học sinh - nhấn mạnh về Tôi).',
        'happy'
    ),
    (
        @DemoUserId3,
        'sensei_va_01',
        N'Sensei giúp em phân biệt trợ từ Ni (に) và De (で) khi chỉ địa điểm với ạ!',
        N'Rất hay! Trợ từ DE (で) dùng cho địa điểm DIỄN RA HÀNH ĐỘNG (ví dụ: Toshokan de hon o yomimasu - Đọc sách ở thư viện). Còn trợ từ NI (に) chỉ ĐỊA ĐIỂM TỒN TẠI hoặc ĐÍCH ĐẾN của chuyển động (ví dụ: Heya ni isu ga arimasu - Ở phòng có cái ghế) nhé em!',
        'explaining'
    ),
    (
        @DemoUserId3,
        'sensei_va_01',
        N'Làm sao để mở bài Paraphrase cho biểu đồ IELTS Writing Task 1 không bị lặp từ?',
        N'Để mở bài Task 1 ấn tượng, em hãy thay đổi cấu trúc chủ ngữ hoặc dùng từ đồng nghĩa! Ví dụ: "The bar chart shows..." -> "The bar chart illustrates/compares...". Và đổi cụm từ chỉ thời gian "between 2000 and 2020" -> "over a twenty-year period starting from 2000" nhé!',
        'encouraging'
    );

    PRINT '✅ [Seed] 3D AI Tutor chat history logs inserted.';
END
GO

-- H. Seeding Leitner Spaced Repetition Flashcards (Hệ thống từ vựng SRS)
DECLARE @DemoUserId4 INT = (SELECT id FROM users WHERE username = 'demo_student');
IF NOT EXISTS (SELECT 1 FROM srs_flashcards_progress WHERE user_id = @DemoUserId4) AND @DemoUserId4 IS NOT NULL
BEGIN
    INSERT INTO srs_flashcards_progress (user_id, word_kanji, box_level, next_review_date, review_count, last_reviewed_at)
    VALUES
    (@DemoUserId4, N'学校 (Gakkou - Trường học)', 4, DATEADD(day, 7, GETDATE()), 5, GETDATE()),
    (@DemoUserId4, N'先生 (Sensei - Giáo viên)', 5, DATEADD(day, 14, GETDATE()), 8, GETDATE()),
    (@DemoUserId4, N'約束 (Yakusoku - Lời hứa)', 2, DATEADD(day, 2, GETDATE()), 2, GETDATE()),
    (@DemoUserId4, N'準備 (Junbi - Chuẩn bị)', 1, CONVERT(DATE, GETDATE()), 1, DATEADD(day, -1, GETDATE())),
    (@DemoUserId4, N'練習 (Renshuu - Luyện tập)', 3, DATEADD(day, 4, GETDATE()), 4, GETDATE());

    PRINT '✅ [Seed] Leitner SRS Flashcards progress inserted.';
END
GO

-- ========================================================================================
-- 11. ENTERPRISE STORED PROCEDURES FOR BACKUP & RESTORE
-- ========================================================================================

-- Procedure A: sp_BackupLanguageAppDB
IF OBJECT_ID('dbo.sp_BackupLanguageAppDB', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_BackupLanguageAppDB;
GO

CREATE PROCEDURE dbo.sp_BackupLanguageAppDB
    @BackupDirectory NVARCHAR(500) = N'/var/opt/mssql/backup',
    @BackupType VARCHAR(10) = 'FULL' -- 'FULL', 'DIFF', or 'LOG'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Timestamp NVARCHAR(50) = REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR, GETDATE(), 120), '-', ''), ' ', '_'), ':', '');
    DECLARE @BackupFile NVARCHAR(1000);
    DECLARE @SQL NVARCHAR(MAX);

    IF @BackupType = 'FULL'
    BEGIN
        SET @BackupFile = @BackupDirectory + N'/LanguageAppDB_FULL_' + @Timestamp + N'.bak';
        BACKUP DATABASE LanguageAppDB TO DISK = @BackupFile
        WITH FORMAT, INIT, NAME = N'LanguageAppDB Full Backup', STATS = 10;
        PRINT '✅ [Backup] FULL database backup created successfully at: ' + @BackupFile;
    END
    ELSE IF @BackupType = 'DIFF'
    BEGIN
        SET @BackupFile = @BackupDirectory + N'/LanguageAppDB_DIFF_' + @Timestamp + N'.bak';
        BACKUP DATABASE LanguageAppDB TO DISK = @BackupFile
        WITH DIFFERENTIAL, NAME = N'LanguageAppDB Differential Backup', STATS = 10;
        PRINT '✅ [Backup] DIFFERENTIAL database backup created successfully at: ' + @BackupFile;
    END
    ELSE
    BEGIN
        PRINT '❌ [Backup Error] Invalid @BackupType. Use FULL or DIFF.';
    END
END
GO

-- Procedure B: sp_RestoreLanguageAppDB_Guidance
IF OBJECT_ID('dbo.sp_RestoreLanguageAppDB_Guidance', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RestoreLanguageAppDB_Guidance;
GO

CREATE PROCEDURE dbo.sp_RestoreLanguageAppDB_Guidance
AS
BEGIN
    SET NOCOUNT ON;
    PRINT '========================================================================================';
    PRINT '🗄️ GUIDANCE FOR RESTORING LanguageAppDB FROM BACKUP FILE';
    PRINT '========================================================================================';
    PRINT 'Example SQL Command to run from master database:';
    PRINT '';
    PRINT 'USE master;';
    PRINT 'ALTER DATABASE LanguageAppDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;';
    PRINT 'RESTORE DATABASE LanguageAppDB';
    PRINT 'FROM DISK = ''/var/opt/mssql/backup/LanguageAppDB_FULL_YYYYMMDD_HHMMSS.bak''';
    PRINT 'WITH REPLACE, STATS = 10;';
    PRINT 'ALTER DATABASE LanguageAppDB SET MULTI_USER;';
    PRINT '========================================================================================';
END
GO

PRINT '========================================================================================';
PRINT '🎉 Microsoft SQL Server Initialization, Enterprise Constraints & Rich Seeding COMPLETE!';
PRINT '========================================================================================';
GO
