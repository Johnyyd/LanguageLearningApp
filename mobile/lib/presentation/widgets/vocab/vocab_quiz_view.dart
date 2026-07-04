import 'package:flutter/material.dart';
import '../../../../domain/entities/vocab_item.dart';
import '../../../../core/theme/app_theme.dart';
import '../common/duo_button.dart';

class VocabQuizView extends StatefulWidget {
    final List<VocabItem> vocabList;
    final VoidCallback? onQuizCompleted;
    final VoidCallback? onNextLesson;

    const VocabQuizView({
        super.key,
        required this.vocabList,
        this.onQuizCompleted,
        this.onNextLesson,
    });

    @override
    State<VocabQuizView> createState() => _VocabQuizViewState();
}

class _VocabQuizViewState extends State<VocabQuizView> {
    int _currentQuestionIndex = 0;
    int _score = 0;
    bool _isAnswered = false;
    int? _selectedOptionIndex;
    late List<String> _options;
    late int _correctOptionIndex;
    bool _isQuizFinished = false;

    @override
    void initState() {
        super.initState();
        _generateQuestion();
    }

    void _generateQuestion() {
        if (widget.vocabList.isEmpty) return;
        
        final currentItem = widget.vocabList[_currentQuestionIndex];
        
        // Get incorrect options from remaining vocab or dummy list
        final allMeanings = widget.vocabList.map((e) => e.meaning).where((m) => m != currentItem.meaning).toList();
        final dummyMeanings = [
            "Mặt trời, ban ngày",
            "Sách, nguồn gốc",
            "Con người, nhân loại",
            "Cây cối, rừng già",
            "Nước, dòng sông",
            "Lửa, sức nóng",
            "Núi cao",
            "Vàng, tiền bạc",
        ].where((m) => m != currentItem.meaning).toList();

        final pool = [...allMeanings, ...dummyMeanings]..shuffle();
        final wrongOptions = pool.take(3).toList();
        
        _options = [...wrongOptions, currentItem.meaning]..shuffle();
        _correctOptionIndex = _options.indexOf(currentItem.meaning);
        _isAnswered = false;
        _selectedOptionIndex = null;
    }

    void _selectOption(int index) {
        if (_isAnswered) return;
        setState(() {
            _isAnswered = true;
            _selectedOptionIndex = index;
            if (index == _correctOptionIndex) {
                _score++;
            }
        });
    }

    void _nextQuestion() {
        if (_currentQuestionIndex < widget.vocabList.length - 1) {
            setState(() {
                _currentQuestionIndex++;
                _generateQuestion();
            });
        } else {
            setState(() {
                _isQuizFinished = true;
            });
            widget.onQuizCompleted?.call();
        }
    }

    void _resetQuiz() {
        setState(() {
            _currentQuestionIndex = 0;
            _score = 0;
            _isQuizFinished = false;
            _generateQuestion();
        });
    }

    @override
    Widget build(BuildContext context) {
        if (widget.vocabList.isEmpty) {
            return const Center(child: Text("Cần ít nhất 1 từ vựng để bắt đầu Quiz."));
        }

        if (_isQuizFinished) {
            final percentage = (_score / widget.vocabList.length) * 100;
            return Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(
                                percentage >= 80 ? Icons.emoji_events : (percentage >= 50 ? Icons.star : Icons.refresh),
                                size: 80,
                                color: percentage >= 80 ? AppColors.goldAccent : AppColors.sakuraPink,
                            ),
                            const SizedBox(height: 16),
                            Text(
                                "Hoàn thành Quiz N5!",
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                "Bạn đã trả lời đúng $_score / ${widget.vocabList.length} câu (${percentage.toStringAsFixed(0)}%)",
                                style: const TextStyle(fontSize: 18, color: AppColors.slateGray),
                            ),
                            const SizedBox(height: 24),
                            Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: AppColors.sakuraPink.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                    percentage >= 80
                                        ? "Xuất sắc! Bạn đã nắm vững các từ vựng N5 trong bài học này!"
                                        : "Hãy cố gắng ôn tập lại Flashcard SRS để đạt kết quả tốt hơn ở lần sau nhé!",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.duoBlue),
                                ),
                            ),
                            const SizedBox(height: 32),
                            if (widget.onNextLesson != null) ...[
                                DuoButton(
                                    text: "Chuyển sang Bài học tiếp theo",
                                    onPressed: widget.onNextLesson,
                                    color: DuoButtonColor.green,
                                ),
                                const SizedBox(height: 12),
                            ],
                            DuoButton(
                                text: "Làm lại Quiz Trắc nghiệm",
                                onPressed: _resetQuiz,
                                color: DuoButtonColor.indigo,
                            ),
                        ],
                    ),
                ),
            );
        }

        final currentItem = widget.vocabList[_currentQuestionIndex];

        return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Progress Header
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text(
                                "Câu hỏi ${_currentQuestionIndex + 1}/${widget.vocabList.length}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slateGray, fontSize: 16),
                            ),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                    color: AppColors.goldAccent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                    "Điểm số: $_score",
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.academicNavy, fontWeight: FontWeight.bold),
                                ),
                            ),
                        ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / widget.vocabList.length,
                        backgroundColor: AppColors.slateGray.withValues(alpha: 0.2),
                        color: AppColors.sakuraPink,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 24),

                    // Question Card
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.duoBlue, width: 2),
                            boxShadow: [
                                BoxShadow(
                                    color: AppColors.duoBlue.withValues(alpha: 0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                ),
                            ],
                        ),
                        child: Column(
                            children: [
                                const Text(
                                    "Nghĩa của từ tiếng Nhật này là gì?",
                                    style: TextStyle(color: Color(0xFF777777), fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                    currentItem.character,
                                    style: const TextStyle(
                                        color: Color(0xFF3C3C3C),
                                        fontSize: 56,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    "[ ${currentItem.romaji} ]",
                                    style: const TextStyle(color: AppColors.duoBlue, fontSize: 18, fontStyle: FontStyle.italic),
                                ),
                            ],
                        ),
                    ),
                    const SizedBox(height: 24),

                    // Options List
                    ...List.generate(_options.length, (index) {
                        final optionText = _options[index];
                        final isSelected = _selectedOptionIndex == index;
                        final isCorrect = index == _correctOptionIndex;

                        Color borderColor = AppColors.slateGray.withValues(alpha: 0.3);
                        Color bgColor = Theme.of(context).cardColor;
                        IconData? iconData;
                        Color iconColor = Colors.transparent;

                        if (_isAnswered) {
                            if (isCorrect) {
                                borderColor = AppColors.successGreen;
                                bgColor = AppColors.successGreen.withValues(alpha: 0.1);
                                iconData = Icons.check_circle;
                                iconColor = AppColors.successGreen;
                            } else if (isSelected) {
                                borderColor = AppColors.errorRed;
                                bgColor = AppColors.errorRed.withValues(alpha: 0.1);
                                iconData = Icons.cancel;
                                iconColor = AppColors.errorRed;
                            }
                        }

                        return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                                onTap: () => _selectOption(index),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: borderColor, width: 2),
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            Expanded(
                                                child: Text(
                                                    "${String.fromCharCode(65 + index)}. $optionText",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: _isAnswered && isCorrect ? FontWeight.bold : FontWeight.w500,
                                                        color: _isAnswered && isCorrect ? AppColors.successGreen : (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.academicNavy),
                                                    ),
                                                ),
                                            ),
                                            if (_isAnswered && iconData != null)
                                                Icon(iconData, color: iconColor),
                                        ],
                                    ),
                                ),
                            ),
                        );
                    }),

                    const SizedBox(height: 16),

                    // Next Question Button
                    if (_isAnswered)
                        DuoButton(
                            text: _currentQuestionIndex < widget.vocabList.length - 1 ? "Câu tiếp theo" : "Xem kết quả Quiz",
                            onPressed: _nextQuestion,
                            color: DuoButtonColor.green,
                        ),
                ],
            ),
        );
    }
}
