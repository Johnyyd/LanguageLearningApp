import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/vocab/vocab_bloc.dart';
import '../blocs/vocab/vocab_state.dart';
import '../widgets/common/3d_avatar_viewer.dart';
import '../../core/theme/app_theme.dart';
import 'n5_dialogue_roleplay_screen.dart';
import 'n5_grammar_builder_screen.dart';
import 'n5_jlpt_mock_exam_screen.dart';

class DashboardScreen extends StatelessWidget {
    final Function(int) onNavigate;

    const DashboardScreen({super.key, required this.onNavigate});

    @override
    Widget build(BuildContext context) {
        final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.deepIndigo;

        return Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            // Header Title
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    "Trang Chủ Học Tập",
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.w800,
                                                        color: textColor,
                                                    ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                    "Hệ thống theo dõi tiến độ & năng lực cá nhân",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors.slateGray.withValues(alpha: 0.9),
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                        ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                            color: AppColors.successGreen.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
                                        ),
                                        child: const Row(
                                            children: [
                                                Icon(Icons.auto_awesome, size: 16, color: AppColors.successGreen),
                                                SizedBox(width: 4),
                                                Text(
                                                    "PRO AI",
                                                    style: TextStyle(
                                                        color: AppColors.successGreen,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                            const SizedBox(height: 20),

                            // 3D Avatar Sensei Hero Greeting Card (REQ-3D-01)
                            Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [AppColors.duoGreen.withValues(alpha: 0.1), Colors.white],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                        color: AppColors.duoGreen.withValues(alpha: 0.3),
                                        width: 1.5,
                                    ),
                                    boxShadow: [
                                        BoxShadow(
                                            color: AppColors.duoGreen.withValues(alpha: 0.1),
                                            blurRadius: 15,
                                            offset: const Offset(0, 6),
                                        ),
                                    ],
                                ),
                                child: Column(
                                    children: [
                                        const Avatar3dViewer(
                                            emotion: "happy",
                                            height: 180,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                            "\"Chào mừng quay trở lại! Sensei đã chuẩn bị sẵn các từ vựng N5 theo lịch ôn tập SRS SuperMemo-2 cho hôm nay.\"",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic,
                                                color: const Color(0xFF3C3C3C),
                                                height: 1.4,
                                            ),
                                            textAlign: TextAlign.center,
                                        ),
                                    ],
                                ),
                            ),
                            const SizedBox(height: 24),

                            // Section Title: Progress Stats (REQ-SEC-02)
                            Text(
                                "Thống Kê Tiến Độ Học Tập",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                ),
                            ),
                            const SizedBox(height: 12),

                            // Streak Card & N5 Vocabulary Progress Cards with dynamic data
                            BlocBuilder<VocabBloc, VocabState>(
                                builder: (context, state) {
                                    int streak = 7;
                                    int totalWords = 12;
                                    int masteredWords = 5;
                                    if (state is VocabLoaded) {
                                        streak = state.streakCount;
                                        totalWords = state.vocabList.isNotEmpty ? state.vocabList.length : 12;
                                        masteredWords = state.vocabList.where((item) => item.srsRepetition > 0).length;
                                    }
                                    final double vocabProgress = totalWords > 0 ? (masteredWords / totalWords).clamp(0.0, 1.0) : 0.0;

                                    return Column(
                                        children: [
                                            // Streak Card
                                            Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context).cardColor,
                                                    borderRadius: BorderRadius.circular(20),
                                                    boxShadow: [
                                                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                                                    ],
                                                    border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.2)),
                                                ),
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                                const Expanded(
                                                                    child: Row(
                                                                        children: [
                                                                            Icon(Icons.local_fire_department, color: AppColors.goldAccent, size: 24),
                                                                            SizedBox(width: 8),
                                                                            Expanded(
                                                                                child: Text(
                                                                                    "Chuỗi Ngày Học Liên Tục (Streak)",
                                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                    decoration: BoxDecoration(
                                                                        color: AppColors.goldAccent.withValues(alpha: 0.15),
                                                                        borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    child: Text(
                                                                        "$streak Ngày",
                                                                        style: const TextStyle(color: AppColors.goldAccent, fontWeight: FontWeight.bold),
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                        const SizedBox(height: 16),
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: ["T2", "T3", "T4", "T5", "T6", "T7", "CN"].map((day) {
                                                                final isToday = day == "CN";
                                                                return Column(
                                                                    children: [
                                                                        Text(day, style: TextStyle(fontSize: 12, color: AppColors.slateGray.withValues(alpha: 0.8))),
                                                                        const SizedBox(height: 6),
                                                                        Container(
                                                                            width: 32,
                                                                            height: 32,
                                                                            decoration: BoxDecoration(
                                                                                color: isToday
                                                                                    ? AppColors.goldAccent
                                                                                    : AppColors.successGreen.withValues(alpha: 0.2),
                                                                                shape: BoxShape.circle,
                                                                                boxShadow: isToday
                                                                                    ? [BoxShadow(color: AppColors.goldAccent.withValues(alpha: 0.4), blurRadius: 8)]
                                                                                    : [],
                                                                            ),
                                                                            child: Icon(
                                                                                isToday ? Icons.star : Icons.check,
                                                                                size: 16,
                                                                                color: isToday ? Colors.white : AppColors.successGreen,
                                                                            ),
                                                                        ),
                                                                    ],
                                                                );
                                                            }).toList(),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            const SizedBox(height: 16),

                                            // N5 Vocabulary SRS Mastery & Kana/Kanji Writing Mastery Row
                                            Row(
                                                children: [
                                                    // N5 SRS Progress
                                                    Expanded(
                                                        child: Container(
                                                            padding: const EdgeInsets.all(16),
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(context).cardColor,
                                                                borderRadius: BorderRadius.circular(20),
                                                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                                                                border: Border.all(color: AppColors.sakuraPink.withValues(alpha: 0.2)),
                                                            ),
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                    const Row(
                                                                        children: [
                                                                            Icon(Icons.style, color: AppColors.sakuraPink, size: 20),
                                                                            SizedBox(width: 6),
                                                                            Expanded(child: Text("Từ Vựng N5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                                                                        ],
                                                                    ),
                                                                    const SizedBox(height: 12),
                                                                    Text("$masteredWords / $totalWords từ", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                                    const SizedBox(height: 4),
                                                                    Text("Đã thuộc (SM-2 SRS)", style: TextStyle(fontSize: 11, color: AppColors.slateGray.withValues(alpha: 0.9))),
                                                                    const SizedBox(height: 10),
                                                                    ClipRRect(
                                                                        borderRadius: BorderRadius.circular(6),
                                                                        child: LinearProgressIndicator(
                                                                            value: vocabProgress,
                                                                            backgroundColor: AppColors.sakuraPink.withValues(alpha: 0.15),
                                                                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sakuraPink),
                                                                            minHeight: 6,
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    // Kana / Kanji Writing Mastery (Thay thế IELTS theo yêu cầu)
                                                    Expanded(
                                                        child: Container(
                                                            padding: const EdgeInsets.all(16),
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(context).cardColor,
                                                                borderRadius: BorderRadius.circular(20),
                                                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                                                                border: Border.all(color: AppColors.softIndigo.withValues(alpha: 0.2)),
                                                            ),
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                    const Row(
                                                                        children: [
                                                                            Icon(Icons.draw, color: AppColors.softIndigo, size: 20),
                                                                            SizedBox(width: 6),
                                                                            Expanded(child: Text("Luyện Viết Kana", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                                                                        ],
                                                                    ),
                                                                    const SizedBox(height: 12),
                                                                    const Text("46 / 46 nét", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.softIndigo)),
                                                                    const SizedBox(height: 4),
                                                                    Text("Độ chính xác nét chữ", style: TextStyle(fontSize: 11, color: AppColors.slateGray.withValues(alpha: 0.9))),
                                                                    const SizedBox(height: 10),
                                                                    ClipRRect(
                                                                        borderRadius: BorderRadius.circular(6),
                                                                        child: LinearProgressIndicator(
                                                                            value: 1.0,
                                                                            backgroundColor: AppColors.softIndigo.withValues(alpha: 0.15),
                                                                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.softIndigo),
                                                                            minHeight: 6,
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ],
                                    );
                                },
                            ),
                            const SizedBox(height: 24),

                            // Section Title: N5 Advanced Modules
                            Text(
                                "Chuyên Đề Năng Lực N5",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                ),
                            ),
                            const SizedBox(height: 12),
                            _buildQuickActionCard(
                                context: context,
                                title: "Luyện Nghe & Đàm Thoại Ngữ Cảnh",
                                subtitle: "Hội thoại thực tế Konbini, Eki, Ramen với Sensei",
                                icon: Icons.record_voice_over,
                                color: AppColors.duoGreen,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const N5DialogueRoleplayScreen())),
                            ),
                            const SizedBox(height: 12),
                            _buildQuickActionCard(
                                context: context,
                                title: "Trạm Ngữ Pháp & Sắp Xếp Câu N5",
                                subtitle: "Kéo thả từ vựng, luyện trợ từ & cấu trúc ngữ pháp",
                                icon: Icons.extension,
                                color: AppColors.duoBlue,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const N5GrammarBuilderScreen())),
                            ),
                            const SizedBox(height: 12),
                            _buildQuickActionCard(
                                context: context,
                                title: "Đề Thi Thử JLPT N5 Tổng Hợp",
                                subtitle: "Đồng hồ bấm giờ 30 phút, chấm điểm thực chiến & lời giải",
                                icon: Icons.assignment_turned_in,
                                color: AppColors.duoYellow,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const N5JlptMockExamScreen())),
                            ),
                            const SizedBox(height: 24),

                            // Section Title: Quick Actions
                            Text(
                                "Lối Tắt Học Tập Nhanh",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                ),
                            ),
                            const SizedBox(height: 12),

                            // Quick Action Cards
                            _buildQuickActionCard(
                                context: context,
                                title: "Luyện Từ Vựng & Viết Kanji N5",
                                subtitle: "Ôn tập flashcard xoay 3D, kiểm tra nét vẽ Kana/Kanji",
                                icon: Icons.language,
                                color: AppColors.sakuraPink,
                                onTap: () => onNavigate(1),
                            ),
                            const SizedBox(height: 12),
                            // Ẩn Chấm Điểm IELTS Writing Task 1 theo yêu cầu tập trung Tiếng Nhật
                            _buildQuickActionCard(
                                context: context,
                                title: "Hỏi Đáp Cùng Trợ Lý 3D Sensei",
                                subtitle: "Trò chuyện giọng nói (Speech-to-Text & TTS)",
                                icon: Icons.smart_toy,
                                color: AppColors.successGreen,
                                onTap: () => onNavigate(2),
                            ),
                            const SizedBox(height: 20),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildQuickActionCard({
        required BuildContext context,
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
    }) {
        // Tham chiếu thiết kế Duolingo: Viền rõ ràng và shadow viền đáy dày 4px tạo hiệu ứng 3D
        final shadowColor = color == AppColors.duoGreen ? AppColors.duoGreenShadow
                          : color == AppColors.duoBlue ? AppColors.duoBlueShadow
                          : color == AppColors.duoYellow ? AppColors.duoYellowShadow
                          : color.withValues(alpha: 0.6);

        return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color, width: 2),
                    boxShadow: [
                        BoxShadow(
                            color: shadowColor,
                            blurRadius: 0,
                            offset: const Offset(0, 4),
                        ),
                    ],
                ),
                child: Row(
                    children: [
                        Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(icon, color: color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: const Color(0xFF3C3C3C),
                                        ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        subtitle,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF777777),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16, color: color),
                    ],
                ),
            ),
        );
    }
}
