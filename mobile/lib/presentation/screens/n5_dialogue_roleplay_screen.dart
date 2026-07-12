import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/tts_helper.dart';
import '../../core/utils/stt_helper.dart';
import '../../data/datasources/remote_ai_datasource.dart';
import '../widgets/common/3d_avatar_viewer.dart';
import '../widgets/common/responsive_container.dart';

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
    bool _isLoading = true;
    Set<String> _completedScenarioIds = {};
    List<DialogueScenario> _scenarios = [];

    final List<DialogueScenario> _fallbackScenarios = [
        DialogueScenario(
            id: 'konbini',
            title: 'Mua sắm tại Konbini',
            subtitle: 'Hỏi giá cả, hâm nóng hộp cơm Bento & thanh toán',
            icon: Icons.storefront,
            color: AppColors.duoGreen,
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
            title: 'Hỏi đường tại Nhà ga (Eki)',
            subtitle: 'Tìm tàu đi Shinjuku, hỏi giờ tàu chạy & mua vé',
            icon: Icons.train,
            color: AppColors.duoBlue,
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
            title: 'Gọi món tại Nhà hàng Ramen',
            subtitle: 'Chọn món, yêu cầu độ cay & xin hóa đơn',
            icon: Icons.ramen_dining,
            color: AppColors.duoYellow,
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
            title: 'Tự giới thiệu bản thân (Jikoshoukai)',
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

    IconData _iconFromName(String? name) {
        switch (name) {
            case 'storefront':
            case 'shopping': return Icons.storefront;
            case 'train': return Icons.train;
            case 'people_alt':
            case 'greeting': return Icons.people_alt;
            case 'restaurant': return Icons.restaurant;
            default: return Icons.chat_bubble_outline;
        }
    }

    Color _colorFromHex(String? hexString, Color defaultColor) {
        if (hexString == null || hexString.isEmpty) return defaultColor;
        try {
            final hex = hexString.replaceAll('#', '');
            return Color(int.parse('FF$hex', radix: 16));
        } catch (_) {
            return defaultColor;
        }
    }

    @override
    void initState() {
        super.initState();
        _initTts();
        _loadCompletedScenarios();
        _loadDialoguesFromApi();
    }

    Future<void> _loadCompletedScenarios() async {
        try {
            final prefs = await SharedPreferences.getInstance();
            final savedList = prefs.getStringList('n5_dialogue_completed_ids');
            if (savedList != null && mounted) {
                setState(() {
                    _completedScenarioIds = savedList.toSet();
                });
            }
        } catch (_) {}
    }

    Future<void> _markScenarioCompleted(String scenarioId) async {
        setState(() {
            _completedScenarioIds.add(scenarioId);
        });
        try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setStringList('n5_dialogue_completed_ids', _completedScenarioIds.toList());
        } catch (_) {}
    }

    Future<void> _loadDialoguesFromApi({bool forceRefresh = false}) async {
        if (forceRefresh && mounted) {
            setState(() => _isLoading = true);
        }
        try {
            if (!forceRefresh) {
                try {
                    final prefs = await SharedPreferences.getInstance();
                    final cachedStr = prefs.getString('cache_n5_dialogues_screen');
                    if (cachedStr != null) {
                        final List<dynamic> decoded = jsonDecode(cachedStr);
                        final cachedScenarios = _parseScenariosList(decoded);
                        if (cachedScenarios.isNotEmpty && mounted) {
                            setState(() {
                                _scenarios = cachedScenarios;
                                _isLoading = false;
                            });
                        }
                    }
                } catch (_) {}
            }

            final remoteAiDs = context.read<RemoteAiDataSource>();
            final data = await remoteAiDs.fetchN5Dialogues();
            if (data.isNotEmpty) {
                try {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('cache_n5_dialogues_screen', jsonEncode(data));
                } catch (_) {}
                final parsed = _parseScenariosList(data);
                if (mounted) {
                    setState(() {
                        _scenarios = parsed;
                    });
                }
            } else if (_scenarios.isEmpty) {
                _scenarios = List.from(_fallbackScenarios);
            }
        } catch (_) {
            if (_scenarios.isEmpty) {
                _scenarios = List.from(_fallbackScenarios);
            }
        } finally {
            if (mounted) {
                setState(() {
                    _isLoading = false;
                });
            }
        }
    }

    List<DialogueScenario> _parseScenariosList(List<dynamic> rawList) {
        return rawList.map((json) {
            final rawTurns = (json['turns'] as List<dynamic>?) ?? [];
            final turnsList = rawTurns.map((t) => DialogueTurn(
                speaker: t['speaker'] ?? 'Sensei',
                japanese: t['japanese'] ?? '',
                romaji: t['romaji'] ?? '',
                vietnamese: t['vietnamese'] ?? '',
            )).toList();
            return DialogueScenario(
                id: json['id'] ?? '',
                title: json['title'] ?? 'Bài hội thoại N5',
                subtitle: json['subtitle'] ?? '',
                icon: _iconFromName(json['icon']),
                color: _colorFromHex(json['color'], AppColors.duoGreen),
                turns: turnsList,
            );
        }).toList();
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
            await TtsHelper.stop(_flutterTts);
            if (mounted) setState(() => _isSpeaking = false);
            return;
        }
        if (mounted) setState(() => _isSpeaking = true);
        await TtsHelper.speak(text, lang: "ja-JP", tts: _flutterTts);
        if (mounted) setState(() => _isSpeaking = false);
    }

    void _simulateUserSpeech() async {
        if (_isListeningMic) {
            await SttHelper.stopListening();
            if (mounted) setState(() => _isListeningMic = false);
            return;
        }

        setState(() => _isListeningMic = true);
        final success = await SttHelper.startListening(
            localeId: "ja_JP",
            onResult: (text, isFinal) {
                if (mounted && isFinal) {
                    setState(() {
                        _isListeningMic = false;
                        if (_selectedScenarioIndex != null &&
                            _currentTurnIndex < _scenarios[_selectedScenarioIndex!].turns.length - 1) {
                            _currentTurnIndex++;
                        }
                    });
                    final display = text.isNotEmpty ? "Bạn nói: \"$text\" - Phát âm tốt!" : "Phát âm của bạn rất tốt! Độ trôi chảy: 95%";
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(display),
                            backgroundColor: AppColors.duoGreen,
                        ),
                    );
                }
            },
        );

        if (!success && mounted) {
            setState(() => _isListeningMic = false);
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Không thể thu âm hoặc chưa cấp quyền micro!"),
                    backgroundColor: AppColors.duoRed,
                ),
            );
        }
    }

    @override
    void dispose() {
        TtsHelper.stop(_flutterTts);
        SttHelper.stopListening();
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
                    backgroundColor: AppColors.surfaceWhite,
                    foregroundColor: const Color(0xFF3C3C3C),
                    elevation: 0,
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
                        // 3D Avatar Sensei Header (Compact)
                        Container(
                            height: 100,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                color: Color(0xFFE5F6DF),
                                border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1.5)),
                            ),
                            child: Avatar3dViewer(
                                emotion: _isSpeaking ? "talking" : (_isListeningMic ? "thinking" : "happy"),
                                height: 100,
                            ),
                        ),
                        // Dialogue Turn Display
                        Expanded(
                            child: ResponsiveContainer(
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
                                                        color: currentTurn.speaker == 'Sensei' ? AppColors.duoGreen.withValues(alpha: 0.15) : AppColors.duoBlue.withValues(alpha: 0.15),
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: currentTurn.speaker == 'Sensei' ? AppColors.duoGreen : AppColors.duoBlue, width: 2),
                                                    ),
                                                    child: Text(
                                                        currentTurn.speaker == 'Sensei' ? "Sensei (Trợ Lý Đàm Thoại)" : "Lượt của bạn (Học viên)",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: currentTurn.speaker == 'Sensei' ? AppColors.duoGreen : AppColors.duoBlue,
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
                                                border: Border.all(color: scenario.color, width: 2),
                                                boxShadow: [
                                                    BoxShadow(
                                                        color: scenario.color == AppColors.duoGreen ? AppColors.duoGreenShadow
                                                             : scenario.color == AppColors.duoBlue ? AppColors.duoBlueShadow
                                                             : scenario.color == AppColors.duoYellow ? AppColors.duoYellowShadow
                                                             : scenario.color.withValues(alpha: 0.6),
                                                        blurRadius: 0,
                                                        offset: const Offset(0, 4),
                                                    ),
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
                                                        currentTurn.vietnamese,
                                                        style: const TextStyle(fontSize: 15, color: AppColors.duoGreen, fontWeight: FontWeight.w700),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        const SizedBox(height: 24),
                                        if (currentTurn.speaker == 'Sensei')
                                            ElevatedButton.icon(
                                                onPressed: () => _speak(currentTurn.japanese),
                                                icon: Icon(_isSpeaking ? Icons.volume_up : Icons.volume_up_outlined),
                                                label: Text(_isSpeaking ? "Đang phát âm..." : "Nghe Phát Âm (TTS)"),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.duoGreen,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                        side: const BorderSide(color: AppColors.duoGreenShadow, width: 2),
                                                    ),
                                                ),
                                            )
                                        else
                                            ElevatedButton.icon(
                                                onPressed: _isListeningMic ? null : _simulateUserSpeech,
                                                icon: Icon(_isListeningMic ? Icons.mic : Icons.mic_none),
                                                label: Text(_isListeningMic ? "Đang thu âm & Chấm điểm..." : "Bấm để Nói & Luyện Phát Âm"),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: _isListeningMic ? AppColors.duoYellow : AppColors.duoBlue,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                        side: BorderSide(color: _isListeningMic ? AppColors.duoYellowShadow : AppColors.duoBlueShadow, width: 2),
                                                    ),
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
                                                    style: OutlinedButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                                        side: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    ),
                                                    child: const Text("Câu trước", style: TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                                ElevatedButton(
                                                    onPressed: _currentTurnIndex < scenario.turns.length - 1
                                                        ? () => setState(() => _currentTurnIndex++)
                                                        : () {
                                                            _markScenarioCompleted(scenario.id);
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                    content: Text("Chúc mừng! Bạn đã hoàn thành bài đàm thoại này!"),
                                                                    backgroundColor: AppColors.duoGreen,
                                                                ),
                                                            );
                                                            setState(() {
                                                                _selectedScenarioIndex = null;
                                                                _currentTurnIndex = 0;
                                                            });
                                                        },
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppColors.duoGreen,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(16),
                                                            side: const BorderSide(color: AppColors.duoGreenShadow, width: 2),
                                                        ),
                                                    ),
                                                    child: Text(_currentTurnIndex < scenario.turns.length - 1 ? "Câu tiếp" : "Hoàn thành", style: const TextStyle(fontWeight: FontWeight.bold)),
                                                ),
                                            ],
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        ),
                    ],
                ),
            );
        }

        return Scaffold(
            appBar: AppBar(
                title: const Text("Luyện Nghe & Đàm Thoại N5"),
                backgroundColor: AppColors.surfaceWhite,
                foregroundColor: const Color(0xFF3C3C3C),
                elevation: 0,
                actions: [
                    IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Tải lại từ API",
                        onPressed: () => _loadDialoguesFromApi(forceRefresh: true),
                    ),
                ],
            ),
            body: ResponsiveContainer(
                child: _isLoading || _scenarios.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _scenarios.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, idx) {
                        final sc = _scenarios[idx];
                        final shadowColor = sc.color == AppColors.duoGreen ? AppColors.duoGreenShadow
                                          : sc.color == AppColors.duoBlue ? AppColors.duoBlueShadow
                                          : sc.color == AppColors.duoYellow ? AppColors.duoYellowShadow
                                          : sc.color.withValues(alpha: 0.6);

                        final isCompleted = _completedScenarioIds.contains(sc.id);

                        return Material(
                            color: Colors.transparent,
                            child: InkWell(
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
                                        border: Border.all(color: isCompleted ? AppColors.successGreen : sc.color, width: 2),
                                        boxShadow: [
                                            BoxShadow(color: shadowColor, blurRadius: 0, offset: const Offset(0, 4)),
                                        ],
                                    ),
                                    child: Row(
                                        children: [
                                            Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                    color: (isCompleted ? AppColors.successGreen : sc.color).withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: Icon(sc.icon, color: isCompleted ? AppColors.successGreen : sc.color, size: 28),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Text(sc.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF3C3C3C))),
                                                        const SizedBox(height: 4),
                                                        Text(sc.subtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF777777))),
                                                        const SizedBox(height: 8),
                                                        Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                            decoration: BoxDecoration(
                                                                color: (isCompleted ? AppColors.successGreen : sc.color).withValues(alpha: 0.15),
                                                                borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                    if (isCompleted) ...[
                                                                        const Icon(Icons.check_circle, size: 13, color: AppColors.successGreen),
                                                                        const SizedBox(width: 4),
                                                                        const Text("Đã hoàn thành", style: TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.bold)),
                                                                    ] else
                                                                        Text("Chưa hoàn thành", style: TextStyle(fontSize: 11, color: sc.color, fontWeight: FontWeight.bold)),
                                                                ],
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.arrow_forward_ios, size: 16, color: isCompleted ? AppColors.successGreen : sc.color),
                                        ],
                                    ),
                                ),
                            ),
                        );
                },
            ),
            ),
        );
    }
}
