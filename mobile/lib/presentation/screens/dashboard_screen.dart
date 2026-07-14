import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../blocs/vocab/vocab_bloc.dart';
import '../blocs/vocab/vocab_state.dart';
import '../widgets/common/responsive_container.dart';
import '../widgets/auth/auth_modal.dart';
import '../../core/theme/app_theme.dart';
import 'n5_dialogue_roleplay_screen.dart';
import 'n5_grammar_builder_screen.dart';
import 'n5_jlpt_mock_exam_screen.dart';
import 'ai_custom_avatar_studio_screen.dart';

class DashboardScreen extends StatefulWidget {
    final Function(int) onNavigate;

    const DashboardScreen({super.key, required this.onNavigate});

    @override
    State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
    String _authUsername = '';
    int _streakCount = 1;
    String _lastActivityDate = '';
    int _effectiveStreak = 1;
    bool _isTodayActive = false;
    bool _isStreakLost = false;

    @override
    void initState() {
        super.initState();
        _loadAuthAndStreak();
    }

    Future<void> _loadAuthAndStreak() async {
        try {
            final prefs = await SharedPreferences.getInstance();
            final username = prefs.getString('auth_username') ?? '';
            final storedStreak = prefs.getInt('streak_count') ?? 1;
            final lastDate = prefs.getString('last_activity_date') ?? '';

            final now = DateTime.now();
            final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
            final yesterday = now.subtract(const Duration(days: 1));
            final yesterdayStr = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

            int calculatedStreak = storedStreak;
            bool todayActive = false;
            bool streakLost = false;

            if (lastDate.isNotEmpty) {
                if (lastDate == todayStr) {
                    todayActive = true;
                } else if (lastDate == yesterdayStr) {
                    todayActive = false;
                } else {
                    calculatedStreak = 0;
                    streakLost = true;
                }
            } else {
                todayActive = true;
            }

            if (mounted) {
                setState(() {
                    _authUsername = username;
                    _streakCount = storedStreak;
                    _lastActivityDate = lastDate;
                    _effectiveStreak = calculatedStreak;
                    _isTodayActive = todayActive;
                    _isStreakLost = streakLost;
                });
            }
        } catch (_) {}
    }

    void _openAuthModal() {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AuthModal(onAuthSuccess: _loadAuthAndStreak),
        );
    }

    Future<void> _checkInStreakToday() async {
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now();
        final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        final yesterday = now.subtract(const Duration(days: 1));
        final yesterdayStr = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

        int newStreak = _streakCount;
        if (_lastActivityDate == yesterdayStr) {
            newStreak = _streakCount + 1;
        } else if (_lastActivityDate != todayStr) {
            newStreak = 1;
        }

        await prefs.setInt('streak_count', newStreak);
        await prefs.setString('last_activity_date', todayStr);

        if (_authUsername.isNotEmpty) {
            try {
                final dio = Dio();
                await dio.post(
                    "${AppConstants.baseUrl}/auth/activity",
                    data: {"username": _authUsername},
                );
            } catch (_) {}
        }

        await _loadAuthAndStreak();
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("🔥 Điểm danh thành công! Chuỗi học tập: $newStreak ngày liên tiếp."),
                    backgroundColor: AppColors.successGreen,
                ),
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.deepIndigo;

        return Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: ResponsiveContainer(
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
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.w800,
                                                            color: textColor,
                                                        ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                        "Hệ thống theo dõi tiến độ & năng lực cá nhân",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: AppColors.slateGray.withValues(alpha: 0.9),
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                    ),
                                                ],
                                            ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                            onTap: _openAuthModal,
                                            borderRadius: BorderRadius.circular(20),
                                            child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                    color: AppColors.sakuraPink.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: AppColors.sakuraPink.withValues(alpha: 0.4)),
                                                ),
                                                child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                        Icon(
                                                            _authUsername.isNotEmpty ? Icons.person : Icons.login_rounded,
                                                            size: 14,
                                                            color: AppColors.sakuraPink,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                            _authUsername.isNotEmpty ? _authUsername : "Đăng nhập",
                                                            style: const TextStyle(
                                                                color: AppColors.sakuraPink,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 11,
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 14),

                                // Compact Greeting Card
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [AppColors.duoGreen.withValues(alpha: 0.12), Colors.white],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: AppColors.duoGreen.withValues(alpha: 0.25),
                                            width: 1.2,
                                        ),
                                        boxShadow: [
                                            BoxShadow(
                                                color: AppColors.duoGreen.withValues(alpha: 0.06),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                            ),
                                        ],
                                    ),
                                    child: Row(
                                        children: [
                                            Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: AppColors.duoGreen.withValues(alpha: 0.15),
                                                    shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                    Icons.tips_and_updates_rounded,
                                                    color: AppColors.duoGreen,
                                                    size: 24,
                                                ),
                                            ),
                                            const SizedBox(width: 14),
                                            const Expanded(
                                                child: Text(
                                                    "\"Chào mừng quay trở lại! Sensei đã chuẩn bị sẵn các từ vựng N5 theo lịch ôn tập SRS SuperMemo-2 cho hôm nay.\"",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontStyle: FontStyle.italic,
                                                        color: Color(0xFF3C3C3C),
                                                        height: 1.35,
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                const SizedBox(height: 18),

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
                                    int totalWords = 0;
                                    int masteredWords = 0;
                                    if (state is VocabLoaded) {
                                        totalWords = state.vocabList.length;
                                        masteredWords = state.vocabList.where((item) => item.srsRepetition > 0).length;
                                    }
                                    final double vocabProgress = totalWords > 0 ? (masteredWords / totalWords).clamp(0.0, 1.0) : 0.0;

                                    final currentWeekday = DateTime.now().weekday;
                                    final daysList = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];

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
                                                                        "$_effectiveStreak Ngày",
                                                                        style: const TextStyle(color: AppColors.goldAccent, fontWeight: FontWeight.bold),
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                        const SizedBox(height: 16),
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: daysList.asMap().entries.map((entry) {
                                                                final idx = entry.key;
                                                                final day = entry.value;
                                                                final isToday = (idx + 1) == currentWeekday;
                                                                final isPastActive = (idx + 1) < currentWeekday && _effectiveStreak > 0;
                                                                return Column(
                                                                    children: [
                                                                        Text(
                                                                            day,
                                                                            style: TextStyle(
                                                                                fontSize: 12,
                                                                                color: isToday ? AppColors.goldAccent : AppColors.slateGray.withValues(alpha: 0.8),
                                                                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                                                            ),
                                                                        ),
                                                                        const SizedBox(height: 6),
                                                                        Container(
                                                                            width: 32,
                                                                            height: 32,
                                                                            decoration: BoxDecoration(
                                                                                color: isToday
                                                                                    ? (_isTodayActive ? AppColors.goldAccent : AppColors.goldAccent.withValues(alpha: 0.2))
                                                                                    : (isPastActive ? AppColors.successGreen.withValues(alpha: 0.2) : AppColors.slateGray.withValues(alpha: 0.1)),
                                                                                shape: BoxShape.circle,
                                                                                boxShadow: isToday
                                                                                    ? [BoxShadow(color: AppColors.goldAccent.withValues(alpha: 0.3), blurRadius: 6)]
                                                                                    : [],
                                                                            ),
                                                                            child: Icon(
                                                                                isToday
                                                                                    ? (_isTodayActive ? Icons.star : Icons.local_fire_department)
                                                                                    : (isPastActive ? Icons.check : Icons.circle_outlined),
                                                                                size: 16,
                                                                                color: isToday
                                                                                    ? (_isTodayActive ? Colors.white : AppColors.goldAccent)
                                                                                    : (isPastActive ? AppColors.successGreen : AppColors.slateGray),
                                                                            ),
                                                                        ),
                                                                    ],
                                                                );
                                                            }).toList(),
                                                        ),
                                                        if (_lastActivityDate.isNotEmpty)
                                                            Padding(
                                                                padding: const EdgeInsets.only(top: 10),
                                                                child: Text(
                                                                    "Hoạt động gần nhất: $_lastActivityDate (Đang tích lũy: $_streakCount ngày)",
                                                                    style: TextStyle(
                                                                        fontSize: 12,
                                                                        color: textColor.withValues(alpha: 0.65),
                                                                        fontStyle: FontStyle.italic,
                                                                    ),
                                                                ),
                                                            ),
                                                        if (!_isTodayActive)
                                                            Container(
                                                                margin: const EdgeInsets.only(top: 12),
                                                                width: double.infinity,
                                                                child: ElevatedButton.icon(
                                                                    onPressed: _checkInStreakToday,
                                                                    style: ElevatedButton.styleFrom(
                                                                        backgroundColor: AppColors.goldAccent,
                                                                        foregroundColor: Colors.white,
                                                                        padding: const EdgeInsets.symmetric(vertical: 11),
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                                        elevation: 2,
                                                                    ),
                                                                    icon: const Icon(Icons.bolt_rounded, size: 18),
                                                                    label: const Text(
                                                                        "Điểm Danh Học Tập Hôm Nay (+1 Streak)",
                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                                    ),
                                                                ),
                                                            )
                                                        else
                                                            Container(
                                                                margin: const EdgeInsets.only(top: 12),
                                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                decoration: BoxDecoration(
                                                                    color: AppColors.successGreen.withValues(alpha: 0.12),
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
                                                                ),
                                                                child: Row(
                                                                    children: [
                                                                        const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 18),
                                                                        const SizedBox(width: 8),
                                                                        Expanded(
                                                                            child: Text(
                                                                                "Đã điểm danh học tập hôm nay! Chuỗi Streak ($_effectiveStreak ngày) đang được duy trì.",
                                                                                style: const TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.w600),
                                                                            ),
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                        if (_isStreakLost)
                                                            Container(
                                                                margin: const EdgeInsets.only(top: 12),
                                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                decoration: BoxDecoration(
                                                                    color: AppColors.crimsonRed.withValues(alpha: 0.1),
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    border: Border.all(color: AppColors.crimsonRed.withValues(alpha: 0.3)),
                                                                ),
                                                                child: const Row(
                                                                    children: [
                                                                        Icon(Icons.warning_amber_rounded, color: AppColors.crimsonRed, size: 18),
                                                                        SizedBox(width: 8),
                                                                        Expanded(
                                                                            child: Text(
                                                                                "Bạn đã mất streak do không có hoạt động học tập ngày qua. Hãy học ngay hôm nay để bắt đầu streak mới!",
                                                                                style: TextStyle(color: AppColors.crimsonRed, fontSize: 12, fontWeight: FontWeight.w600),
                                                                            ),
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                        if (_authUsername.isEmpty)
                                                            Container(
                                                                margin: const EdgeInsets.only(top: 14),
                                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                decoration: BoxDecoration(
                                                                    color: AppColors.goldAccent.withValues(alpha: 0.1),
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.3)),
                                                                ),
                                                                child: Row(
                                                                    children: [
                                                                        const Icon(Icons.lock_outline_rounded, color: AppColors.goldAccent, size: 18),
                                                                        const SizedBox(width: 8),
                                                                        const Expanded(
                                                                            child: Text(
                                                                                "Đăng nhập để lưu lại chuỗi Streak & đồng bộ trên máy chủ!",
                                                                                style: TextStyle(color: AppColors.goldAccent, fontSize: 12, fontWeight: FontWeight.w600),
                                                                            ),
                                                                        ),
                                                                        TextButton(
                                                                            onPressed: _openAuthModal,
                                                                            style: TextButton.styleFrom(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                minimumSize: Size.zero,
                                                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                            ),
                                                                            child: const Text("Đăng nhập", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.goldAccent)),
                                                                        ),
                                                                    ],
                                                                ),
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
                                onTap: () => widget.onNavigate(1),
                            ),
                            const SizedBox(height: 12),
                            // Ẩn Chấm Điểm IELTS Writing Task 1 theo yêu cầu tập trung Tiếng Nhật
                            _buildQuickActionCard(
                                context: context,
                                title: "Hỏi Đáp Cùng Trợ Lý 3D Sensei",
                                subtitle: "Trò chuyện giọng nói (Speech-to-Text & TTS)",
                                icon: Icons.smart_toy,
                                color: AppColors.successGreen,
                                onTap: () => widget.onNavigate(2),
                            ),
                            const SizedBox(height: 12),
                            _buildQuickActionCard(
                                context: context,
                                title: "3D VTuber Studio (Tiếng Nhật)",
                                subtitle: "Tùy chỉnh Sensei, kiểm thử Visemes & giọng Anime VA",
                                icon: Icons.face_retouching_natural,
                                color: AppColors.sakuraPink,
                                onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const AiCustomAvatarStudioScreen()),
                                    );
                                },
                            ),
                            const SizedBox(height: 20),
                        ],
                    ),
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
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: Color(0xFF3C3C3C),
                                        ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                        subtitle,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF777777),
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
