import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/vocab/vocab_bloc.dart';
import '../blocs/vocab/vocab_event.dart';
import '../blocs/vocab/vocab_state.dart';
import '../widgets/vocab/flip_flashcard.dart';
import '../widgets/vocab/handwriting_canvas.dart';
import '../widgets/vocab/vocab_quiz_view.dart';
import '../widgets/common/responsive_container.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JapaneseScreen extends StatefulWidget {
    const JapaneseScreen({super.key});

    @override
    State<JapaneseScreen> createState() => _JapaneseScreenState();
}

class _JapaneseScreenState extends State<JapaneseScreen> with SingleTickerProviderStateMixin {
    late TabController _tabController;
    int _currentIndex = 0;
    int _currentLesson = 1;
    Set<int> _completedLessons = {};

    @override
    void initState() {
        super.initState();
        _tabController = TabController(length: 3, vsync: this);
        _loadCompletedLessons();
        context.read<VocabBloc>().add(LoadVocabList(lessonId: _currentLesson));
    }

    Future<void> _loadCompletedLessons() async {
        try {
            final prefs = await SharedPreferences.getInstance();
            final list = prefs.getStringList('japanese_completed_lessons');
            if (list != null && mounted) {
                setState(() {
                    _completedLessons = list.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
                });
            }
        } catch (_) {}
    }

    Future<void> _markLessonCompleted(int lessonId) async {
        setState(() {
            _completedLessons.add(lessonId);
        });
        try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setStringList('japanese_completed_lessons', _completedLessons.map((e) => e.toString()).toList());
        } catch (_) {}
    }

    @override
    void dispose() {
        _tabController.dispose();
        super.dispose();
    }

    void _switchLesson(int lessonId) {
        if (_currentLesson == lessonId) return;
        setState(() {
            _currentLesson = lessonId;
            _currentIndex = 0;
        });
        context.read<VocabBloc>().add(LoadVocabList(lessonId: lessonId, forceRefresh: false));
    }

    void _advanceToNextLesson() {
        if (_currentLesson < 5) {
            _switchLesson(_currentLesson + 1);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("🎉 Chào mừng đến với Bài $_currentLesson! Hãy chinh phục từ vựng mới nào!"),
                    backgroundColor: AppColors.successGreen,
                ),
            );
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("🏆 Chúc mừng! Bạn đã hoàn thành toàn bộ 5 Bài học N5! Hãy ôn tập lại nhé!"),
                    backgroundColor: AppColors.goldAccent,
                ),
            );
            _switchLesson(1);
        }
    }

    void _showLessonCompletionDialog() {
        _markLessonCompleted(_currentLesson);
        showModalBottomSheet(
            context: context,
            backgroundColor: Theme.of(context).cardColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        const Icon(Icons.emoji_events, size: 64, color: AppColors.goldAccent),
                        const SizedBox(height: 16),
                        Text(
                            "🎉 Hoàn thành Bài $_currentLesson!",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.sakuraPink),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            "Bạn đã học hết từ vựng của Bài $_currentLesson. Bạn có muốn chuyển sang Bài học mới để tránh lặp lại từ cũ không?",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 24),
                        Row(
                            children: [
                                Expanded(
                                    child: OutlinedButton(
                                        onPressed: () {
                                            Navigator.pop(context);
                                            setState(() => _currentIndex = 0);
                                        },
                                        style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        child: const Text("Ôn lại bài này"),
                                    ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: ElevatedButton.icon(
                                        onPressed: () {
                                            Navigator.pop(context);
                                            _advanceToNextLesson();
                                        },
                                        icon: const Icon(Icons.arrow_forward),
                                        label: const Text("Bài tiếp theo"),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.successGreen,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ],
                ),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("🎌 Tiếng Nhật N5 (SRS & Nét viết)"),
                bottom: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.sakuraPink,
                    unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    indicatorColor: AppColors.sakuraPink,
                    tabs: const [
                        Tab(icon: Icon(Icons.style), text: "Flashcard SRS"),
                        Tab(icon: Icon(Icons.gesture), text: "Luyện viết Nét"),
                        Tab(icon: Icon(Icons.quiz), text: "Quiz Trắc nghiệm"),
                    ],
                ),
            ),
            body: BlocBuilder<VocabBloc, VocabState>(
                builder: (context, state) {
                    if (state is VocabLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.sakuraPink));
                    } else if (state is VocabError) {
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.errorRed),
                                        const SizedBox(height: 16),
                                        Text(
                                            state.message.contains("connection timeout") || state.message.contains("Connection refused") || state.message.contains("SocketException")
                                                ? "Không thể kết nối đến máy chủ AI (${AppConstants.baseUrl}).\nVui lòng đảm bảo backend đang chạy và thử lại."
                                                : state.message,
                                            style: const TextStyle(color: AppColors.errorRed, fontSize: 16),
                                            textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton.icon(
                                            onPressed: () => context.read<VocabBloc>().add(LoadVocabList(forceRefresh: true, lessonId: _currentLesson)),
                                            icon: const Icon(Icons.refresh),
                                            label: const Text("Thử lại ngay"),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.sakuraPink,
                                                foregroundColor: AppColors.deepIndigo,
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        );
                    } else if (state is VocabLoaded) {
                        final vocabList = state.vocabList;
                        if (vocabList.isEmpty) {
                            return const Center(child: Text("Hiện chưa có từ vựng N5 trong kho."));
                        }
                        final currentItem = vocabList[_currentIndex % vocabList.length];

                        return Column(
                            children: [
                                // Horizontal Lesson Selector Bar
                                Container(
                                    height: 56,
                                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: 5,
                                        itemBuilder: (context, idx) {
                                            final lessonNum = idx + 1;
                                            final isSelected = _currentLesson == lessonNum;
                                            final isDone = _completedLessons.contains(lessonNum);
                                            final titles = ["Bài 1: Hiragana", "Bài 2: Katakana", "Bài 3: Kanji Cơ bản", "Bài 4: Số đếm & Thời gian", "Bài 5: Gia đình & Chào hỏi"];
                                            return Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: ChoiceChip(
                                                    label: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                            if (isDone) ...[
                                                                const Icon(Icons.check_circle, size: 14, color: AppColors.successGreen),
                                                                const SizedBox(width: 4),
                                                            ],
                                                            Text(titles[idx]),
                                                        ],
                                                    ),
                                                    selected: isSelected,
                                                    onSelected: (selected) {
                                                        if (selected) _switchLesson(lessonNum);
                                                    },
                                                    selectedColor: AppColors.sakuraPink,
                                                    labelStyle: TextStyle(
                                                        color: isSelected ? AppColors.deepIndigo : Theme.of(context).textTheme.bodyLarge?.color,
                                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                    ),
                                                    backgroundColor: Theme.of(context).cardColor,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                        side: BorderSide(
                                                            color: isSelected ? AppColors.sakuraPink : AppColors.slateGray.withValues(alpha: 0.3),
                                                        ),
                                                    ),
                                                ),
                                            );
                                        },
                                    ),
                                ),
                                // Main Tab Content
                                Expanded(
                                    child: ResponsiveContainer(
                                        child: TabBarView(
                                            controller: _tabController,
                                            children: [
                                                // Tab 1: Flashcard SRS
                                                SingleChildScrollView(
                                                    padding: const EdgeInsets.all(20),
                                                    child: Column(
                                                        children: [
                                                            Row(
                                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                 children: [
                                                                     Text("Thẻ ${_currentIndex + 1}/${vocabList.length}", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7))),
                                                                     Container(
                                                                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                                         decoration: BoxDecoration(color: AppColors.successGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                                                         child: Text("🔥 Streak: ${state.streakCount} ngày", style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold)),
                                                                     ),
                                                                 ],
                                                            ),
                                                            const SizedBox(height: 16),
                                                            FlipFlashcard(
                                                                 item: currentItem,
                                                                 onSrsReviewed: (quality) {
                                                                     context.read<VocabBloc>().add(SubmitSrsReview(currentItem, quality));
                                                                     if (_currentIndex >= vocabList.length - 1) {
                                                                         _showLessonCompletionDialog();
                                                                     } else {
                                                                         setState(() {
                                                                             _currentIndex = (_currentIndex + 1) % vocabList.length;
                                                                         });
                                                                     }
                                                                 },
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Row(
                                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                 children: [
                                                                     ElevatedButton.icon(
                                                                         onPressed: () => setState(() => _currentIndex = (_currentIndex - 1 + vocabList.length) % vocabList.length),
                                                                         icon: const Icon(Icons.arrow_back, size: 20),
                                                                         label: const Text("Trước"),
                                                                         style: ElevatedButton.styleFrom(
                                                                             backgroundColor: Theme.of(context).cardColor,
                                                                             foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                                                                             elevation: 2,
                                                                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                                             shape: RoundedRectangleBorder(
                                                                                 borderRadius: BorderRadius.circular(16),
                                                                                 side: BorderSide(color: AppColors.slateGray.withValues(alpha: 0.3)),
                                                                             ),
                                                                         ),
                                                                     ),
                                                                     ElevatedButton.icon(
                                                                         onPressed: () {
                                                                             if (_currentIndex >= vocabList.length - 1) {
                                                                                 _showLessonCompletionDialog();
                                                                             } else {
                                                                                 setState(() => _currentIndex = (_currentIndex + 1) % vocabList.length);
                                                                             }
                                                                         },
                                                                         icon: const Icon(Icons.arrow_forward, size: 20),
                                                                         label: const Text("Tiếp theo"),
                                                                         style: ElevatedButton.styleFrom(
                                                                             backgroundColor: AppColors.sakuraPink,
                                                                             foregroundColor: AppColors.deepIndigo,
                                                                             elevation: 4,
                                                                             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                             textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                         ),
                                                                     ),
                                                                 ],
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                // Tab 2: Handwriting Practice
                                                SingleChildScrollView(
                                                    padding: const EdgeInsets.all(20),
                                                    child: Column(
                                                        children: [
                                                            Text("Hãy dùng ngón tay vẽ lại chữ \"${currentItem.character}\"", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                            const SizedBox(height: 8),
                                                            Text("Nghĩa: ${currentItem.meaning}", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8))),
                                                            const SizedBox(height: 20),
                                                            HandwritingCanvas(
                                                                key: ValueKey('${currentItem.id}_$_currentIndex'),
                                                                targetCharacter: currentItem.character,
                                                                onClear: () {
                                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã làm mới bảng vẽ!"), duration: Duration(seconds: 1)));
                                                                },
                                                            ),
                                                            const SizedBox(height: 20),
                                                            SizedBox(
                                                                width: double.infinity,
                                                                child: ElevatedButton.icon(
                                                                    onPressed: () {
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                            const SnackBar(
                                                                                content: Text("🎉 Nét vẽ rất tốt! Hệ thống đã ghi nhận tiến bộ viết chữ Kana/Kanji."),
                                                                                backgroundColor: AppColors.successGreen,
                                                                            ),
                                                                        );
                                                                        if (_currentIndex >= vocabList.length - 1) {
                                                                            _showLessonCompletionDialog();
                                                                        } else {
                                                                            setState(() => _currentIndex = (_currentIndex + 1) % vocabList.length);
                                                                        }
                                                                    },
                                                                    icon: const Icon(Icons.check_circle),
                                                                    label: const Text("Hoàn thành & Sang chữ tiếp theo"),
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor: AppColors.successGreen,
                                                                        foregroundColor: Colors.white,
                                                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                // Tab 3: Multiple Choice Quiz
                                                VocabQuizView(
                                                    vocabList: vocabList,
                                                    onQuizCompleted: () {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                                content: Text("🎉 Chúc mừng! Bạn đã hoàn thành bài kiểm tra trắc nghiệm từ vựng N5!"),
                                                                backgroundColor: AppColors.goldAccent,
                                                            ),
                                                        );
                                                    },
                                                    onNextLesson: _advanceToNextLesson,
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                            ],
                        );
                    }
                    return const SizedBox();
                },
            ),
        );
    }
}
