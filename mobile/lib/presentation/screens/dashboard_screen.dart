import 'package:flutter/material.dart';
import '../widgets/common/3d_avatar_viewer.dart';
import '../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
    final Function(int) onNavigate;

    const DashboardScreen({super.key, required this.onNavigate});

    @override
    Widget build(BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
                                                    "🌟 AI Study Dashboard",
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.bold,
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
                                        colors: isDark
                                            ? [AppColors.deepIndigo, AppColors.softIndigo]
                                            : [AppColors.sakuraPink.withValues(alpha: 0.15), Colors.white],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                        color: AppColors.sakuraPink.withValues(alpha: 0.3),
                                        width: 1.5,
                                    ),
                                    boxShadow: [
                                        BoxShadow(
                                            color: AppColors.sakuraPink.withValues(alpha: 0.1),
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
                                            "\"Chào mừng quay trở lại! Sensei đã chuẩn bị sẵn các từ vựng N5 theo lịch ôn tập SRS SuperMemo-2 và đề IELTS mới nhất cho hôm nay.\"",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic,
                                                color: isDark ? Colors.white70 : AppColors.deepIndigo,
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
                                "🔥 Thống Kê Tiến Độ Học Tập",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                ),
                            ),
                            const SizedBox(height: 12),

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
                                                Expanded(
                                                    child: Row(
                                                        children: [
                                                            const Icon(Icons.local_fire_department, color: AppColors.goldAccent, size: 24),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                                child: Text(
                                                                    "Chuỗi Ngày Học Liên Tục (Streak)",
                                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                                                    child: const Text(
                                                        "7 Ngày 🔥",
                                                        style: TextStyle(color: AppColors.goldAccent, fontWeight: FontWeight.bold),
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

                            // N5 Vocabulary SRS Mastery & IELTS Score Row
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
                                                            Text("Từ Vựng N5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                                        ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    const Text("45 / 120 từ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 4),
                                                    Text("Đã thuộc (SM-2 SRS)", style: TextStyle(fontSize: 11, color: AppColors.slateGray.withValues(alpha: 0.9))),
                                                    const SizedBox(height: 10),
                                                    ClipRRect(
                                                        borderRadius: BorderRadius.circular(6),
                                                        child: LinearProgressIndicator(
                                                            value: 45 / 120,
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
                                                            Text("Luyện Viết Kana", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                            const SizedBox(height: 24),

                            // Section Title: Quick Actions
                            Text(
                                "🚀 Lối Tắt Học Tập Nhanh",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
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
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDark ? Colors.white : AppColors.deepIndigo,
                                        ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        subtitle,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.slateGray.withValues(alpha: 0.9),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.slateGray),
                    ],
                ),
            ),
        );
    }
}
