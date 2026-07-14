import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/remote_ai_datasource.dart';

class MockQuestion {
    final String id;
    final String section; // 'Từ vựng', 'Ngữ pháp', 'Đọc hiểu'
    final String question;
    final List<String> options;
    final int correctOptionIndex;
    final String explanation;

    MockQuestion({
        required this.id,
        required this.section,
        required this.question,
        required this.options,
        required this.correctOptionIndex,
        required this.explanation,
    });
}

class N5JlptMockExamScreen extends StatefulWidget {
    const N5JlptMockExamScreen({super.key});

    @override
    State<N5JlptMockExamScreen> createState() => _N5JlptMockExamScreenState();
}

class _N5JlptMockExamScreenState extends State<N5JlptMockExamScreen> {
    int _remainingSeconds = 30 * 60; // 30 minutes
    Timer? _timer;
    bool _isSubmitted = false;
    final Map<int, int> _selectedAnswers = {}; // questionIdx -> selectedOptionIdx

    bool _isLoading = true;
    List<MockQuestion> _questions = [];

    final List<MockQuestion> _fallbackQuestions = [
        // Từ vựng & Chữ Hán
        MockQuestion(
            id: 'q1',
            section: 'Từ vựng & Chữ Hán',
            question: 'Hãy chọn cách đọc đúng của từ chữ Hán: 「学生」',
            options: ['がくせい (gakusei)', 'きょうし (kyoushi)', 'せんでい (sendei)', 'だいがく (daigaku)'],
            correctOptionIndex: 0,
            explanation: '「学生」đọc là がくせい (gakusei - học sinh, sinh viên).',
        ),
        MockQuestion(
            id: 'q2',
            section: 'Từ vựng & Chữ Hán',
            question: 'Điền từ thích hợp vào chỗ trống: 「あしたは＿＿＿＿に行きます。」(Ngày mai tôi đi ngân hàng)',
            options: ['びょういん (byouin)', 'ぎんこう (ginkou)', 'ゆうびんきょく (yuubinkyoku)', 'えき (eki)'],
            correctOptionIndex: 1,
            explanation: 'ぎんこう (ginkou) có nghĩa là Ngân hàng.',
        ),
        MockQuestion(
            id: 'q3',
            section: 'Từ vựng & Chữ Hán',
            question: 'Chữ Hán 「水」có cách đọc là gì?',
            options: ['みず (mizu)', 'ひ (hi)', 'き (ki)', 'つち (tsuchi)'],
            correctOptionIndex: 0,
            explanation: '「水」đọc là みず (mizu - nước).',
        ),
        // Ngữ pháp
        MockQuestion(
            id: 'q4',
            section: 'Ngữ pháp',
            question: 'Chọn trợ từ đúng: 「わたし＿＿＿ベトナム人です。」',
            options: ['が (ga)', 'を (wo)', 'は (wa)', 'に (ni)'],
            correctOptionIndex: 2,
            explanation: 'Trợ từ "は" (wa) dùng để chỉ chủ ngữ trong câu nói về bản thân hoặc định danh.',
        ),
        MockQuestion(
            id: 'q5',
            section: 'Ngữ pháp',
            question: 'Chọn cấu trúc thể lịch sự đúng: 「きのう、レストランでラーメンを＿＿＿＿＿。」(Hôm qua tôi đã ăn ramen)',
            options: ['たべます (tabemasu)', 'たべました (tabemashita)', 'たべません (tabemasen)', 'たべたい (tabetai)'],
            correctOptionIndex: 1,
            explanation: 'Vì có thời gian trong quá khứ (きのう - hôm qua), động từ phải chia về thì quá khứ khẳng định "たべました".',
        ),
        MockQuestion(
            id: 'q6',
            section: 'Ngữ pháp',
            question: '「ここに あたまを ＿＿＿＿＿ ください。」(Xin vui lòng không đội mũ ở đây)',
            options: ['かぶらないで (kaburanaide)', 'かぶって (kabutte)', 'かぶります (kaburimasu)', 'かぶらない (kaburanai)'],
            correctOptionIndex: 0,
            explanation: 'Cấu trúc V-ないでください dùng để yêu cầu ai đó xin đừng làm việc gì.',
        ),
        // Đọc hiểu
        MockQuestion(
            id: 'q7',
            section: 'Đọc hiểu',
            question: 'Đoạn văn: 「田中さんは毎日６時に起きます。朝ごはんを食べてから、７時半に電車で会社へ行きます。」\nCâu hỏi: 田中さんはどうやって会社へ行きますか？ (Anh Tanaka đi làm bằng gì?)',
            options: ['バスで (bằng xe buýt)', 'あるいて (だ bộ)', 'でんしゃで (bằng tàu điện)', 'じてんしゃで (bằng xe đạp)'],
            correctOptionIndex: 2,
            explanation: 'Trong bài viết: 「７時半にでんしゃ（電車）で会社へ行きます」=> Bằng tàu điện.',
        ),
        MockQuestion(
            id: 'q8',
            section: 'Đọc hiểu',
            question: 'Đoạn văn: 「きょうは日曜日です。学校はありません。わたしは部屋の掃除をします。それから、友達と映画を見ます。」\nCâu hỏi: きょう、この人は何をしますか？ (Hôm nay người này làm những gì?)',
            options: ['Gặp thầy giáo ở trường', 'Dọn dẹp phòng và đi xem phim với bạn', 'Đi làm thêm ở konbini', 'Ở nhà ngủ cả ngày'],
            correctOptionIndex: 1,
            explanation: 'Trong bài: 「部屋の掃除をします。それから、友達と映画を見ます」=> Dọn phòng và xem phim.',
        ),
    ];

    @override
    void initState() {
        super.initState();
        _startTimer();
        _loadQuestionsFromApi();
    }

    Future<void> _loadQuestionsFromApi({bool forceRefresh = false}) async {
        final remoteAiDs = context.read<RemoteAiDataSource>();
        if (forceRefresh && mounted) {
            setState(() => _isLoading = true);
        }
        try {
            if (!forceRefresh) {
                try {
                    final prefs = await SharedPreferences.getInstance();
                    final cachedStr = prefs.getString('cache_n5_mock_exam_screen');
                    if (cachedStr != null) {
                        final List<dynamic> decoded = jsonDecode(cachedStr);
                        final cachedQuestions = _parseQuestionsList(decoded);
                        if (cachedQuestions.isNotEmpty && mounted) {
                            setState(() {
                                _questions = cachedQuestions;
                                _isLoading = false;
                            });
                        }
                    }
                } catch (_) {}
            }

            if (!mounted) return;
            final data = await remoteAiDs.fetchN5MockExamQuestions();
            if (data.isNotEmpty) {
                try {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('cache_n5_mock_exam_screen', jsonEncode(data));
                } catch (_) {}
                final parsed = _parseQuestionsList(data);
                if (mounted) {
                    setState(() {
                        _questions = parsed;
                    });
                }
            } else if (_questions.isEmpty) {
                _questions = List.from(_fallbackQuestions);
            }
        } catch (_) {
            if (_questions.isEmpty) {
                _questions = List.from(_fallbackQuestions);
            }
        } finally {
            if (mounted) {
                setState(() {
                    _isLoading = false;
                });
            }
        }
    }

    List<MockQuestion> _parseQuestionsList(List<dynamic> rawList) {
        return rawList.map((json) => MockQuestion(
            id: json['id'] ?? '',
            section: json['section'] ?? 'Từ vựng & Chữ Hán',
            question: json['question'] ?? '',
            options: List<String>.from(json['options'] ?? []),
            correctOptionIndex: json['correctOptionIndex'] ?? 0,
            explanation: json['explanation'] ?? '',
        )).toList();
    }

    void _startTimer() {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (_remainingSeconds > 0 && !_isSubmitted) {
                setState(() => _remainingSeconds--);
            } else if (_remainingSeconds == 0 && !_isSubmitted) {
                _submitExam();
            }
        });
    }

    void _submitExam() {
        setState(() => _isSubmitted = true);
        _timer?.cancel();
        _showResultDialog();
    }

    String _formatTime(int totalSecs) {
        final mins = (totalSecs / 60).floor().toString().padLeft(2, '0');
        final secs = (totalSecs % 60).toString().padLeft(2, '0');
        return "$mins:$secs";
    }

    void _showResultDialog() {
        int correctCount = 0;
        for (int i = 0; i < _questions.length; i++) {
            if (_selectedAnswers[i] == _questions[i].correctOptionIndex) {
                correctCount++;
            }
        }
        final int score = (correctCount / _questions.length * 180).round();
        final bool isPass = score >= 80; // Pass mark ~ 80/180

        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).cardColor,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Icon(isPass ? Icons.emoji_events : Icons.refresh, size: 64, color: isPass ? AppColors.duoYellow : AppColors.duoYellow),
                        const SizedBox(height: 16),
                        Text(
                            isPass ? "CHÚC MỪNG! BẠN ĐÃ ĐỖ ĐỀ THI THỬ JLPT N5" : "HÃY CỐ GẮNG HƠN Ở LẦN THI TỚI!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isPass ? AppColors.duoGreen : AppColors.duoYellow),
                        ),
                        const SizedBox(height: 12),
                        Text(
                            "Tổng điểm năng lực của bạn: $score / 180 điểm\n(Số câu đúng: $correctCount / ${_questions.length} câu)",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: AppColors.softIndigo.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                                isPass
                                    ? "AI Sensei Nhận Xét: Nền tảng Từ vựng & Ngữ pháp của bạn rất vững chắc! Bạn đã sẵn sàng chinh phục kỳ thi JLPT N5 thực tế với mục tiêu điểm cao!"
                                    : "AI Sensei Nhận Xét: Hãy dành thêm thời gian ôn luyện lại Trạm Ngữ pháp và Đàm thoại nhé, Sensei sẽ luôn đồng hành cùng bạn!",
                                style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () {
                                    Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.duoGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: const BorderSide(color: AppColors.duoGreenShadow, width: 2),
                                    ),
                                ),
                                child: const Text("Xem Chi Tiết Đáp Án & Lời Giải AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    @override
    void dispose() {
        _timer?.cancel();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("Đề Thi Thử JLPT N5"),
                backgroundColor: AppColors.duoBlue,
                foregroundColor: Colors.white,
                actions: [
                    IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Tải lại từ API",
                        onPressed: () => _loadQuestionsFromApi(forceRefresh: true),
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                            color: _remainingSeconds <= 300 ? AppColors.errorRed : AppColors.duoYellow,
                            borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                            children: [
                                const Icon(Icons.timer, size: 18, color: AppColors.duoBlue),
                                const SizedBox(width: 6),
                                Text(
                                    _formatTime(_remainingSeconds),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.duoBlue, fontSize: 15),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
            body: Column(
                children: [
                    // Banner Sensei
                    Container(
                        padding: const EdgeInsets.all(12),
                        color: AppColors.softIndigo.withValues(alpha: 0.15),
                        child: Row(
                            children: [
                                const Icon(Icons.info_outline, color: AppColors.softIndigo),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(
                                        _isSubmitted
                                            ? "Bạn đã nộp bài. Hãy kiểm tra các đáp án và lời giải chi tiết bên dưới!"
                                            : "Thời gian làm bài 30 phút. Bạn có thể thay đổi đáp án trước khi bấm Nộp Bài.",
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    Expanded(
                        child: _isLoading || _questions.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _questions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 20),
                            itemBuilder: (context, qIdx) {
                                final q = _questions[qIdx];
                                final isSelected = _selectedAnswers.containsKey(qIdx);
                                final selectedOpt = _selectedAnswers[qIdx];
                                final isCorrectOpt = selectedOpt == q.correctOptionIndex;

                                return Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: _isSubmitted
                                                ? (isCorrectOpt ? AppColors.duoGreen : AppColors.errorRed)
                                                : (isSelected ? AppColors.duoBlue : Colors.transparent),
                                            width: 2,
                                        ),
                                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                    ),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                        decoration: BoxDecoration(
                                                            color: AppColors.deepIndigo.withValues(alpha: 0.1),
                                                            borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(q.section, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepIndigo)),
                                                    ),
                                                    Text("Câu ${qIdx + 1} / ${_questions.length}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slateGray)),
                                                ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(q.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.4)),
                                            const SizedBox(height: 16),
                                            ...q.options.asMap().entries.map((optEntry) {
                                                final optIdx = optEntry.key;
                                                final optText = optEntry.value;
                                                final isThisSelected = selectedOpt == optIdx;
                                                final isThisCorrect = optIdx == q.correctOptionIndex;

                                                Color btnColor = Theme.of(context).cardColor;
                                                Color borderColor = AppColors.slateGray.withValues(alpha: 0.3);
                                                if (_isSubmitted) {
                                                    if (isThisCorrect) {
                                                        btnColor = AppColors.duoGreen.withValues(alpha: 0.2);
                                                        borderColor = AppColors.duoGreen;
                                                    } else if (isThisSelected && !isThisCorrect) {
                                                        btnColor = AppColors.errorRed.withValues(alpha: 0.2);
                                                        borderColor = AppColors.errorRed;
                                                    }
                                                } else if (isThisSelected) {
                                                    btnColor = AppColors.duoBlue.withValues(alpha: 0.15);
                                                    borderColor = AppColors.duoBlue;
                                                }

                                                return Padding(
                                                    padding: const EdgeInsets.only(bottom: 10),
                                                    child: InkWell(
                                                        onTap: _isSubmitted
                                                            ? null
                                                            : () {
                                                                setState(() {
                                                                    _selectedAnswers[qIdx] = optIdx;
                                                                });
                                                            },
                                                        borderRadius: BorderRadius.circular(14),
                                                        child: Container(
                                                            padding: const EdgeInsets.all(14),
                                                            decoration: BoxDecoration(
                                                                color: btnColor,
                                                                borderRadius: BorderRadius.circular(14),
                                                                border: Border.all(color: borderColor, width: 1.5),
                                                            ),
                                                            child: Row(
                                                                children: [
                                                                    Icon(
                                                                        _isSubmitted
                                                                            ? (isThisCorrect ? Icons.check_circle : (isThisSelected ? Icons.cancel : Icons.radio_button_unchecked))
                                                                            : (isThisSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                                                                        color: _isSubmitted
                                                                            ? (isThisCorrect ? AppColors.duoGreen : (isThisSelected ? AppColors.errorRed : AppColors.slateGray))
                                                                            : (isThisSelected ? AppColors.duoBlue : AppColors.slateGray),
                                                                    ),
                                                                    const SizedBox(width: 12),
                                                                    Expanded(
                                                                        child: Text(
                                                                            optText,
                                                                            style: TextStyle(
                                                                                fontWeight: isThisSelected ? FontWeight.bold : FontWeight.normal,
                                                                                fontSize: 15,
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                    ),
                                                );
                                            }),
                                            if (_isSubmitted) ...[
                                                const SizedBox(height: 8),
                                                Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                        color: AppColors.duoYellow.withValues(alpha: 0.15),
                                                        borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            const Icon(Icons.lightbulb, color: AppColors.duoYellow, size: 20),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                                child: Text(
                                                                    "Giải thích: ${q.explanation}",
                                                                    style: const TextStyle(fontSize: 13, height: 1.4),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ],
                                    ),
                                );
                            },
                        ),
                    ),
                ],
            ),
            bottomNavigationBar: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -4))],
                ),
                child: SafeArea(
                    child: ElevatedButton.icon(
                        onPressed: _isSubmitted ? null : _submitExam,
                        icon: Icon(_isSubmitted ? Icons.check : Icons.send),
                        label: Text(_isSubmitted ? "ĐÃ NỘP BÀI" : "NỘP BÀI THI & CHẤM ĐIỂM AI", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _isSubmitted ? AppColors.slateGray : AppColors.duoGreen,
                            foregroundColor: Colors.white,
                            elevation: _isSubmitted ? 0 : 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: _isSubmitted ? Colors.transparent : AppColors.duoGreenShadow,
                                    width: _isSubmitted ? 0 : 4,
                                ),
                            ),
                        ),
                    ),
                ),
            ),
        );
    }
}
