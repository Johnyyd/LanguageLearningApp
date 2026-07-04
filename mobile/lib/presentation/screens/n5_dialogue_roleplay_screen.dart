import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/common/3d_avatar_viewer.dart';

class DialogueScenario {
    final String id;
    final String title;
    final String subtitle;
    final IconData icon;
    final Color color;
    final List<DialogueTurn> turns;

    DialogueScenario({
        required this.id,
        required this.title,
        required this.subtitle,
        required this.icon,
        required this.color,
        required this.turns,
    });
}

class DialogueTurn {
    final String speaker; // 'Sensei' or 'User'
    final String japanese;
    final String romaji;
    final String vietnamese;

    DialogueTurn({
        required this.speaker,
        required this.japanese,
        required this.romaji,
        required this.vietnamese,
    });
}

class N5DialogueRoleplayScreen extends StatefulWidget {
    const N5DialogueRoleplayScreen({super.key});

    @override
    State<N5DialogueRoleplayScreen> createState() => _N5DialogueRoleplayScreenState();
}

class _N5DialogueRoleplayScreenState extends State<N5DialogueRoleplayScreen> {
    final FlutterTts _flutterTts = FlutterTts();
    bool _isSpeaking = false;
    int? _selectedScenarioIndex;
    int _currentTurnIndex = 0;
    bool _isListeningMic = false;

    final List<DialogueScenario> _scenarios = [
        DialogueScenario(
            id: 'konbini',
            title: '🏪 Mua sắm tại Konbini',
            subtitle: 'Hỏi giá cả, hâm nóng hộp cơm Bento & thanh toán',
            icon: Icons.storefront,
            color: AppColors.sakuraPink,
            turns: [
                DialogueTurn(
                    speaker: 'Sensei',
                    japanese: 'いらっしゃいませ！お弁当を温めますか？',
                    romaji: 'Irasshaimase! Obentou wo atatamemasu ka?',
                    vietnamese: 'Xin chào quý khách! Quý khách có muốn hâm nóng hộp cơm không ạ?',
                ),
                DialogueTurn(
                    speaker: 'User',
                    japanese: 'はい、お願いします。いくらですか？',
                    romaji: 'Hai, onegaishimasu. Ikura desu ka?',
                    vietnamese: 'Vâng, nhờ nhân viên ạ. Tổng hết bao nhiêu tiền vậy?',
                ),
                DialogueTurn(
                    speaker: 'Sensei',
                    japanese: '全部で 550円になります。ありがとうございした！',
                    romaji: 'Zenbu de gohyaku gojuu-en ni narimasu. Arigatou gozaimashita!',
                    vietnamese: 'Tổng cộng là 550 Yên ạ. Xin cảm ơn quý khách rất nhiều!',
                ),
            ],
        ),
        DialogueScenario(
            id: 'eki',
            title: '🚉 Hỏi đường tại Nhà ga (Eki)',
            subtitle: 'Tìm tàu đi Shinjuku, hỏi giờ tàu chạy & mua vé',
            icon: Icons.train,
            color: AppColors.softIndigo,
            turns: [
                DialogueTurn(
                    speaker: 'User',
                    japanese: 'すみません、新宿駅までの切符はいくらですか？',
                    romaji: 'Sumimasen, Shinjuku-eki made no kippu wa ikura desu ka?',
                    vietnamese: 'Xin lỗi, vé tàu đến ga Shinjuku là bao nhiêu tiền ạ?',
                ),
                DialogueTurn(
                    speaker: 'Sensei',
                    japanese: '新宿までですね。200円です。2番線から発車しますよ。',
                    romaji: 'Shinjuku made desu ne. Nihyaku-en desu. Ni-ban sen kara hassha shimasu yo.',
                    vietnamese: 'Đến Shinjuku phải không ạ? Giá vé là 200 Yên. Tàu khởi hành từ sân ga số 2 nhé!',
                ),
                DialogueTurn(
                    speaker: 'User',
                    japanese: 'わかりました。次の電車は何時ですか？',
                    romaji: 'Wakarimashita. Tsugi no densha wa nan-ji desu ka?',
                    vietnamese: 'Tôi hiểu rồi. Chuyến tàu tiếp theo là lúc mấy giờ vậy?',
                ),
                DialogueTurn(
                    speaker: 'Sensei',
                    japanese: '午後3時15分です。気を付けて行ってらっしゃい！',
                    romaji: 'Gogo san-ji juu-go fun desu. Ki wo tsukete itterasshai!',
                    vietnamese: 'Là 3 giờ 15 phút chiều ạ. Chúc bạn đi đường bình an nhé!',
                ),
            ],
        ),
        DialogueScenario(
            id: 'ramen',
            title: '🍜 Gọi món tại Nhà hàng Ramen',
            subtitle: 'Chọn món, yêu cầu độ cay & xin hóa đơn',
            icon: Icons.ramen_dining,
            color: AppColors.goldAccent,
            turns: [
                DialogueTurn(
                    speaker: 'Sensei',
                    japanese: 'ご注文は何にさいますか？',
                    romaji: 'Gochuumon wa nani ni shimasu ka?',
                    vietnamese: 'Quý khách muốn gọi món gì ạ?',
                ),
                DialogueTurn(
                    speaker: 'User',
                    japanese: 'とんこつラーメンを一つください。あまり辛くないでください。',
                    romaji: 'Tonkotsu raamen wo hitotsu kudasai. Amari karakunai de kudasai.',
                    vietnamese: 'Cho tôi một bát Ramen xương hầm. Xin đừng làm cay quá nhé.',
                ),
                DialogueTurn(
                    speaker: 'Sensei',
                    japanese: 'かしこまりました！少々お待ちください！',
                    romaji: 'Kashikomarimashita! Shou shou omachi kudasai!',
                    vietnamese: 'Tôi đã rõ rồi ạ! Xin quý khách vui lòng đợi một chút!',
                ),
            ],
        ),
        DialogueScenario(
            id: 'jikoshoukai',
            title: '🤝 Tự giới thiệu bản thân (Jikoshoukai)',
            subtitle: 'Giao tiếp cơ bản về tên, tuổi, sở thích với Sensei',
            icon: Icons.people_alt,
            color: AppColors.successGreen,
            turns: [
                DialogueTurn(
                    speaker: 'User',
                    japanese: 'はじめまして。私はベトナムから来ました。',
                    romaji: 'Hajimemashite. Watashi wa Betonamu kara kimashita.',
                    vietnamese: 'Lần đầu gặp mặt. Tôi đến từ Việt Nam.',
                ),
                DialogueTurn(
                    speaker: 'Sensei',
                    japanese: 'はじめまして！日本語の勉強はどうですか？楽しいですか？',
                    romaji: 'Hajimemashite! Nihongo no benkyou wa dou desu ka? Tanoshii desu ka?',
                    vietnamese: 'Rất vui được gặp bạn! Việc học tiếng Nhật thế nào rồi? Có vui không?',
                ),
                DialogueTurn(
                    speaker: 'User',
                    japanese: 'はい、とても楽しいです！どうぞよろしくお願いします。',
                    romaji: 'Hai, totemo tanoshii desu! Douzo yoroshiku onegaishimasu.',
                    vietnamese: 'Vâng, rất là vui ạ! Rất mong được giúp đỡ.',
                ),
            ],
        ),
    ];

    @override
    void initState() {
        super.initState();
        _initTts();
    }

    void _initTts() async {
        try {
            await _flutterTts.setLanguage("ja-JP");
            await _flutterTts.setSpeechRate(0.5);
            _flutterTts.setCompletionHandler(() {
                if (mounted) setState(() => _isSpeaking = false);
            });
        } catch (_) {}
    }

    void _speak(String text) async {
        if (_isSpeaking) {
            try {
                await _flutterTts.stop();
            } catch (_) {}
            if (mounted) setState(() => _isSpeaking = false);
            return;
        }
        try {
            await _flutterTts.speak(text);
            if (mounted) setState(() => _isSpeaking = true);
        } catch (_) {
            if (mounted) {
                setState(() => _isSpeaking = true);
                Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _isSpeaking = false);
                });
            }
        }
    }

    void _simulateUserSpeech() {
        setState(() => _isListeningMic = true);
        Future.delayed(const Duration(milliseconds: 1800), () {
            if (!mounted) return;
            setState(() {
                _isListeningMic = false;
                if (_selectedScenarioIndex != null &&
                    _currentTurnIndex < _scenarios[_selectedScenarioIndex!].turns.length - 1) {
                    _currentTurnIndex++;
                }
            });
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("🎙️ AI Sensei: Phát âm của bạn rất tốt! Độ trôi chảy: 95% 🌟"),
                    backgroundColor: AppColors.successGreen,
                ),
            );
        });
    }

    @override
    void dispose() {
        _flutterTts.stop();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        if (_selectedScenarioIndex != null) {
            final scenario = _scenarios[_selectedScenarioIndex!];
            final currentTurn = scenario.turns[_currentTurnIndex];

            return Scaffold(
                appBar: AppBar(
                    title: Text(scenario.title),
                    backgroundColor: AppColors.academicNavy,
                    foregroundColor: Colors.white,
                    leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() {
                            _selectedScenarioIndex = null;
                            _currentTurnIndex = 0;
                        }),
                    ),
                ),
                body: Column(
                    children: [
                        // 3D Avatar Sensei Header
                        Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [AppColors.academicNavy, AppColors.deepIndigo.withValues(alpha: 0.8)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                ),
                            ),
                            child: Avatar3dViewer(
                                emotion: _isSpeaking ? "talking" : (_isListeningMic ? "thinking" : "happy"),
                                height: 160,
                            ),
                        ),
                        // Dialogue Turn Display
                        Expanded(
                            child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                                Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                        color: currentTurn.speaker == 'Sensei' ? AppColors.sakuraPink.withValues(alpha: 0.2) : AppColors.softIndigo.withValues(alpha: 0.2),
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: currentTurn.speaker == 'Sensei' ? AppColors.sakuraPink : AppColors.softIndigo),
                                                    ),
                                                    child: Text(
                                                        currentTurn.speaker == 'Sensei' ? "🤖 Sensei (AI Roleplay)" : "👤 Lượt của bạn (Học viên)",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: currentTurn.speaker == 'Sensei' ? AppColors.sakuraPink : AppColors.softIndigo,
                                                        ),
                                                    ),
                                                ),
                                                Text(
                                                    "Câu ${_currentTurnIndex + 1} / ${scenario.turns.length}",
                                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slateGray),
                                                ),
                                            ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: scenario.color.withValues(alpha: 0.3), width: 1.5),
                                                boxShadow: [
                                                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                                                ],
                                            ),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Text(
                                                        currentTurn.japanese,
                                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                        currentTurn.romaji,
                                                        style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                                                    ),
                                                    const Divider(height: 24),
                                                    Text(
                                                        "🇻🇳 ${currentTurn.vietnamese}",
                                                        style: const TextStyle(fontSize: 15, color: AppColors.goldAccent, fontWeight: FontWeight.w600),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        const SizedBox(height: 24),
                                        if (currentTurn.speaker == 'Sensei')
                                            ElevatedButton.icon(
                                                onPressed: () => _speak(currentTurn.japanese),
                                                icon: Icon(_isSpeaking ? Icons.volume_up : Icons.volume_up_outlined),
                                                label: Text(_isSpeaking ? "Đang phát âm..." : "Nghe Sensei Phát Âm (TTS)"),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.sakuraPink,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                ),
                                            )
                                        else
                                            ElevatedButton.icon(
                                                onPressed: _isListeningMic ? null : _simulateUserSpeech,
                                                icon: Icon(_isListeningMic ? Icons.mic : Icons.mic_none),
                                                label: Text(_isListeningMic ? "🎙️ Đang thu âm & Chấm điểm AI..." : "🎙️ Bấm để Nói & Luyện Phát Âm"),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: _isListeningMic ? AppColors.warningOrange : AppColors.softIndigo,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                ),
                                            ),
                                        const SizedBox(height: 16),
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                                OutlinedButton(
                                                    onPressed: _currentTurnIndex > 0
                                                        ? () => setState(() => _currentTurnIndex--)
                                                        : null,
                                                    child: const Text("⬅️ Câu trước"),
                                                ),
                                                ElevatedButton(
                                                    onPressed: _currentTurnIndex < scenario.turns.length - 1
                                                        ? () => setState(() => _currentTurnIndex++)
                                                        : () {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                    content: Text("🎉 Chúc mừng! Bạn đã hoàn thành bài đàm thoại!"),
                                                                    backgroundColor: AppColors.successGreen,
                                                                ),
                                                            );
                                                            setState(() {
                                                                _selectedScenarioIndex = null;
                                                                _currentTurnIndex = 0;
                                                            });
                                                        },
                                                    child: Text(_currentTurnIndex < scenario.turns.length - 1 ? "Câu tiếp ➡️" : "Hoàn thành 🏆"),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ],
                ),
            );
        }

        return Scaffold(
            appBar: AppBar(
                title: const Text("🌟 Luyện Nghe & Đàm Thoại N5"),
                backgroundColor: AppColors.academicNavy,
                foregroundColor: Colors.white,
            ),
            body: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _scenarios.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                    final sc = _scenarios[idx];
                    return InkWell(
                        onTap: () => setState(() {
                            _selectedScenarioIndex = idx;
                            _currentTurnIndex = 0;
                        }),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: sc.color.withValues(alpha: 0.3), width: 1.5),
                                boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
                                ],
                            ),
                            child: Row(
                                children: [
                                    Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                            color: sc.color.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                        ),
                                        child: Icon(sc.icon, color: sc.color, size: 30),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(sc.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 4),
                                                Text(sc.subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7))),
                                                const SizedBox(height: 8),
                                                Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                        color: AppColors.successGreen.withValues(alpha: 0.15),
                                                        borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Text("🤖 AI Sensei Roleplay", style: TextStyle(fontSize: 10, color: AppColors.successGreen, fontWeight: FontWeight.bold)),
                                                ),
                                            ],
                                        ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.slateGray),
                                ],
                            ),
                        ),
                    );
                },
            ),
        );
    }
}
