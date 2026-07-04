import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/common/3d_avatar_viewer.dart';

class GrammarExercise {
    final String id;
    final String title;
    final String grammarPoint;
    final String vietnamesePrompt;
    final List<String> correctWords;
    final List<String> shuffledWords;
    final String aiExplanation;

    GrammarExercise({
        required this.id,
        required this.title,
        required this.grammarPoint,
        required this.vietnamesePrompt,
        required this.correctWords,
        required this.shuffledWords,
        required this.aiExplanation,
    });
}

class N5GrammarBuilderScreen extends StatefulWidget {
    const N5GrammarBuilderScreen({super.key});

    @override
    State<N5GrammarBuilderScreen> createState() => _N5GrammarBuilderScreenState();
}

class _N5GrammarBuilderScreenState extends State<N5GrammarBuilderScreen> {
    int _currentExerciseIndex = 0;
    List<String> _selectedWords = [];
    List<String> _remainingWords = [];
    bool? _isCorrect;
    bool _showExplanation = false;

    final List<GrammarExercise> _exercises = [
        GrammarExercise(
            id: 'gram_01',
            title: 'Cấu trúc Danh từ cơ bản N1 は N2 です',
            grammarPoint: '~は~です (Là...)',
            vietnamesePrompt: 'Tôi là sinh viên người Việt Nam.',
            correctWords: ['わたし', 'は', 'ベトナムの', 'がくせい', 'です'],
            shuffledWords: ['です', 'ベトナムの', 'わたし', 'がくせい', 'は'],
            aiExplanation: 'Trợ từ "は" (đọc là wa) đứng sau chủ ngữ "わたし". Cấu trúc chuẩn là: Chủ ngữ + は + Bổ ngữ + です.',
        ),
        GrammarExercise(
            id: 'gram_02',
            title: 'Trợ từ chỉ tân ngữ trực tiếp を',
            grammarPoint: '~を V (làm cái gì đó)',
            vietnamesePrompt: 'Tôi ăn táo ở nhà hàng.',
            correctWords: ['レストラン', 'で', 'りんご', 'を', 'たべます'],
            shuffledWords: ['を', 'たべます', 'レストラン', 'りんご', 'で'],
            aiExplanation: 'Trợ từ "で" chỉ nơi diễn ra hành động (レストランで). Trợ từ "を" chỉ đối tượng của hành động ăn (りんごをたべます).',
        ),
        GrammarExercise(
            id: 'gram_03',
            title: 'Động từ thể Te ~てください (Yêu cầu/Nhờ vả)',
            grammarPoint: '~てください (Hãy làm...)',
            vietnamesePrompt: 'Xin vui lòng mở cửa giúp tôi.',
            correctWords: ['すみませんが', 'ドア', 'を', 'あけて', 'ください'],
            shuffledWords: ['ドア', 'ください', 'すみませんが', 'あけて', 'を'],
            aiExplanation: 'Động từ "あけます" (mở) chuyển sang thể Te là "あけて". Ghép với "ください" để tạo lời yêu cầu lịch sự.',
        ),
        GrammarExercise(
            id: 'gram_04',
            title: 'Trợ từ chỉ hướng đi / mục đích に và へ',
            grammarPoint: '~に/へ いきます (Đi đến...)',
            vietnamesePrompt: 'Ngày mai tôi sẽ đi Tokyo bằng tàu điện.',
            correctWords: ['あした', 'でんしゃ', 'で', 'とうきょう', 'へ', 'いきます'],
            shuffledWords: ['へ', 'あした', 'で', 'とうきょう', 'でんしゃ', 'いきます'],
            aiExplanation: 'Trợ từ "で" chỉ phương tiện giao thông (でんしゃで - bằng tàu điện). Trợ từ "へ" (đọc là e) chỉ phương hướng di chuyển tới Tokyo.',
        ),
    ];

    @override
    void initState() {
        super.initState();
        _loadExercise(_currentExerciseIndex);
    }

    void _loadExercise(int index) {
        setState(() {
            _currentExerciseIndex = index;
            _remainingWords = List.from(_exercises[index].shuffledWords);
            _selectedWords = [];
            _isCorrect = null;
            _showExplanation = false;
        });
    }

    void _selectWord(String word, int index) {
        if (_isCorrect == true) return;
        setState(() {
            _remainingWords.removeAt(index);
            _selectedWords.add(word);
            _isCorrect = null;
        });
    }

    void _deselectWord(String word, int index) {
        if (_isCorrect == true) return;
        setState(() {
            _selectedWords.removeAt(index);
            _remainingWords.add(word);
            _isCorrect = null;
        });
    }

    void _checkAnswer() {
        final currentEx = _exercises[_currentExerciseIndex];
        final isMatch = _selectedWords.join(' ') == currentEx.correctWords.join(' ');
        setState(() {
            _isCorrect = isMatch;
            _showExplanation = true;
        });
    }

    @override
    Widget build(BuildContext context) {
        final currentEx = _exercises[_currentExerciseIndex];

        return Scaffold(
            appBar: AppBar(
                title: const Text("🧩 Trạm Luyện Ngữ Pháp N5"),
                backgroundColor: AppColors.academicNavy,
                foregroundColor: Colors.white,
            ),
            body: Column(
                children: [
                    // Top AI Sensei Feedback Header
                    Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [AppColors.academicNavy, AppColors.deepIndigo.withValues(alpha: 0.85)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                            ),
                        ),
                        child: Avatar3dViewer(
                            emotion: _isCorrect == true ? "happy" : (_isCorrect == false ? "thinking" : "idle"),
                            height: 140,
                        ),
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                    // Progress and Lesson Badge
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                    color: AppColors.sakuraPink.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                    currentEx.grammarPoint,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.sakuraPink),
                                                ),
                                            ),
                                            Text(
                                                "Bài ${_currentExerciseIndex + 1} / ${_exercises.length}",
                                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slateGray),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Prompt Card
                                    Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.4)),
                                        ),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                const Text("🇻🇳 Hãy sắp xếp câu tiếng Nhật tương ứng:", style: TextStyle(fontSize: 13, color: AppColors.goldAccent, fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 8),
                                                Text(
                                                    currentEx.vietnamesePrompt,
                                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                ),
                                            ],
                                        ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Target Drop Box
                                    const Text("👉 Câu trả lời của bạn (Bấm vào từ bên dưới để điền):", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.slateGray)),
                                    const SizedBox(height: 8),
                                    Container(
                                        constraints: const BoxConstraints(minHeight: 80),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: _isCorrect == true
                                                ? AppColors.successGreen.withValues(alpha: 0.1)
                                                : (_isCorrect == false ? AppColors.errorRed.withValues(alpha: 0.1) : Theme.of(context).cardColor),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                                color: _isCorrect == true
                                                    ? AppColors.successGreen
                                                    : (_isCorrect == false ? AppColors.errorRed : AppColors.softIndigo.withValues(alpha: 0.5)),
                                                width: 2,
                                                style: BorderStyle.solid,
                                            ),
                                        ),
                                        child: _selectedWords.isEmpty
                                            ? const Center(child: Text("... [Khu vực đặt từ] ...", style: TextStyle(color: AppColors.slateGray, fontStyle: FontStyle.italic)))
                                            : Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: _selectedWords.asMap().entries.map((entry) {
                                                    final idx = entry.key;
                                                    final word = entry.value;
                                                    return InkWell(
                                                        onTap: () => _deselectWord(word, idx),
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                            decoration: BoxDecoration(
                                                                color: AppColors.softIndigo,
                                                                borderRadius: BorderRadius.circular(10),
                                                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                                                            ),
                                                            child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                    Text(word, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                                                    const SizedBox(width: 6),
                                                                    const Icon(Icons.close, size: 14, color: Colors.white70),
                                                                ],
                                                            ),
                                                        ),
                                                    );
                                                }).toList(),
                                            ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Available Shuffled Words
                                    const Text("🔀 Các từ gợi ý:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.slateGray)),
                                    const SizedBox(height: 8),
                                    Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: _remainingWords.asMap().entries.map((entry) {
                                            final idx = entry.key;
                                            final word = entry.value;
                                            return InkWell(
                                                onTap: () => _selectWord(word, idx),
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context).cardColor,
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: AppColors.sakuraPink.withValues(alpha: 0.5), width: 1.5),
                                                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 3))],
                                                    ),
                                                    child: Text(word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                ),
                                            );
                                        }).toList(),
                                    ),
                                    const SizedBox(height: 24),
                                    // AI Explanation Box
                                    if (_showExplanation)
                                        Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                                color: _isCorrect == true ? AppColors.successGreen.withValues(alpha: 0.15) : AppColors.warningOrange.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: _isCorrect == true ? AppColors.successGreen : AppColors.warningOrange),
                                            ),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Row(
                                                        children: [
                                                            Icon(_isCorrect == true ? Icons.check_circle : Icons.lightbulb, color: _isCorrect == true ? AppColors.successGreen : AppColors.warningOrange),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                                _isCorrect == true ? "🎉 Chính xác! Bạn rất tuyệt!" : "💡 Sensei Giải thích Ngữ pháp:",
                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _isCorrect == true ? AppColors.successGreen : AppColors.warningOrange),
                                                            ),
                                                        ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(currentEx.aiExplanation, style: const TextStyle(fontSize: 14, height: 1.4)),
                                                ],
                                            ),
                                        ),
                                    const SizedBox(height: 24),
                                    // Action Buttons
                                    Row(
                                        children: [
                                            Expanded(
                                                child: OutlinedButton.icon(
                                                    onPressed: () => _loadExercise(_currentExerciseIndex),
                                                    icon: const Icon(Icons.refresh),
                                                    label: const Text("Làm lại"),
                                                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                                                ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                                flex: 2,
                                                child: ElevatedButton.icon(
                                                    onPressed: _selectedWords.isEmpty
                                                        ? null
                                                        : (_isCorrect == true
                                                            ? () {
                                                                if (_currentExerciseIndex < _exercises.length - 1) {
                                                                    _loadExercise(_currentExerciseIndex + 1);
                                                                } else {
                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                        const SnackBar(content: Text("🏆 Chúc mừng bạn đã hoàn thành toàn bộ chuyên đề ngữ pháp N5!"), backgroundColor: AppColors.goldAccent),
                                                                    );
                                                                    _loadExercise(0);
                                                                }
                                                            }
                                                            : _checkAnswer),
                                                    icon: Icon(_isCorrect == true ? Icons.arrow_forward : Icons.auto_awesome),
                                                    label: Text(_isCorrect == true ? "Bài tiếp theo ➡️" : "Kiểm tra với Sensei"),
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor: _isCorrect == true ? AppColors.successGreen : AppColors.goldAccent,
                                                        foregroundColor: AppColors.academicNavy,
                                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 30),
                                ],
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}
