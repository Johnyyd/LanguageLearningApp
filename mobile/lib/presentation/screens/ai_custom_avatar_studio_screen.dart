import 'dart:convert' show base64Encode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/common/3d_avatar_viewer.dart';
import '../widgets/common/responsive_container.dart';

class AiCustomAvatarStudioScreen extends StatefulWidget {
    const AiCustomAvatarStudioScreen({super.key});

    @override
    State<AiCustomAvatarStudioScreen> createState() => _AiCustomAvatarStudioScreenState();
}

class _AiCustomAvatarStudioScreenState extends State<AiCustomAvatarStudioScreen> {
    final FlutterTts _flutterTts = FlutterTts();
    
    // State cấu hình Sensei
    String? _avatarUrl;
    String _vaName = "Kana Hanazawa (VA)";
    String _speakerId = "sensei_va_01";
    double _speechRate = 0.5;
    double _pitch = 1.1;

    // State kiểm thử trực tiếp
    String _currentEmotion = "idle";
    bool _isSpeaking = false;
    String _activeViseme = "";

    final List<Map<String, dynamic>> _voiceProfiles = [
        {
            "id": "sensei_va_01",
            "name": "Kana Hanazawa (VA)",
            "style": "Nữ - Dịu dàng, chuẩn Tokyo N5",
            "pitch": 1.1,
            "rate": 0.5,
            "color": AppColors.sakuraPink,
            "icon": Icons.face_3,
            "sample": "こんにちは！私はカナです。一緒に日本語を楽しく勉強しましょう！",
        },
        {
            "id": "sensei_va_02",
            "name": "Rie Takahashi (VA)",
            "style": "Nữ - Năng động, vui tươi, tràn đầy năng lượng",
            "pitch": 1.25,
            "rate": 0.55,
            "color": AppColors.warningOrange,
            "icon": Icons.auto_awesome,
            "sample": "やッほー！リエだよ！今日のＮ５文法、気合い入れていこうね！",
        },
        {
            "id": "sensei_va_male",
            "name": "Hiroshi Kamiya (VA)",
            "style": "Nam - Trầm ấm, rõ ràng, phong cách chuẩn mực",
            "pitch": 0.85,
            "rate": 0.5,
            "color": AppColors.duoBlue,
            "icon": Icons.face,
            "sample": "はじめまして。先生のヒロシです。毎日コツコツ復習することが大切です。",
        },
    ];

    final List<Map<String, String>> _visemes = [
        {"char": "あ (A)", "phoneme": "あ", "desc": "Mở rộng môi"},
        {"char": "い (I)", "phoneme": "い", "desc": "Kéo căng ngang"},
        {"char": "う (U)", "phoneme": "う", "desc": "Chụm môi tròn"},
        {"char": "え (E)", "phoneme": "え", "desc": "Mở vừa ngang"},
        {"char": "お (O)", "phoneme": "お", "desc": "Mở tròn sâu"},
    ];

    @override
    void initState() {
        super.initState();
        _initTtsAndLoadPrefs();
    }

    Future<void> _initTtsAndLoadPrefs() async {
        await _flutterTts.setLanguage("ja-JP");
        await _flutterTts.setSpeechRate(_speechRate);
        await _flutterTts.setPitch(_pitch);

        _flutterTts.setStartHandler(() {
            if (mounted) {
                setState(() {
                    _isSpeaking = true;
                    _currentEmotion = "talking";
                });
            }
        });

        _flutterTts.setCompletionHandler(() {
            if (mounted) {
                setState(() {
                    _isSpeaking = false;
                    _currentEmotion = "happy";
                    _activeViseme = "";
                });
            }
        });

        final prefs = await SharedPreferences.getInstance();
        if (mounted) {
            setState(() {
                _avatarUrl = prefs.getString("custom_avatar_url");
                _vaName = prefs.getString("custom_va_name") ?? "Kana Hanazawa (VA)";
                _speakerId = prefs.getString("custom_speaker_id") ?? "sensei_va_01";
                _speechRate = prefs.getDouble("custom_tts_speed") ?? 0.5;
                _pitch = prefs.getDouble("custom_tts_pitch") ?? 1.1;
            });
            await _flutterTts.setSpeechRate(_speechRate);
            await _flutterTts.setPitch(_pitch);
        }
    }

    @override
    void dispose() {
        _flutterTts.stop();
        super.dispose();
    }

    Future<void> _saveAndSync() async {
        HapticFeedback.heavyImpact();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("custom_avatar_url", _avatarUrl ?? "");
        await prefs.setString("custom_va_name", _vaName);
        await prefs.setString("custom_speaker_id", _speakerId);
        await prefs.setDouble("custom_tts_speed", _speechRate);
        await prefs.setDouble("custom_tts_pitch", _pitch);

        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Row(
                        children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text("Đã lưu & đồng bộ thiết lập Sensei cho toàn bộ ứng dụng!"),
                        ],
                    ),
                    backgroundColor: AppColors.duoGreen,
                    behavior: SnackBarBehavior.floating,
                ),
            );
            Navigator.pop(context, true);
        }
    }

    Future<void> _pickCustom3dFile() async {
        HapticFeedback.mediumImpact();
        try {
            final result = await FilePicker.platform.pickFiles(
                type: FileType.any,
                withData: true,
            );
            if (result != null && result.files.isNotEmpty) {
                final file = result.files.single;
                String? targetUrl;
                if (file.bytes != null) {
                    final base64Str = base64Encode(file.bytes!);
                    if (file.name.toLowerCase().endsWith('.gltf')) {
                        targetUrl = 'data:model/gltf+json;base64,$base64Str';
                    } else {
                        targetUrl = 'data:model/gltf-binary;base64,$base64Str';
                    }
                } else if (file.path != null) {
                    targetUrl = file.path!;
                    if (!targetUrl.startsWith("file://") && !targetUrl.startsWith("http") && !targetUrl.startsWith("assets") && !targetUrl.startsWith("data:")) {
                        targetUrl = "file://$targetUrl";
                    }
                }

                if (targetUrl != null && targetUrl.isNotEmpty) {
                    setState(() {
                        _avatarUrl = targetUrl;
                        _vaName = "Custom 3D (${file.name})";
                    });
                    if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Đã nạp file 3D '${file.name}' vào Studio!"),
                                backgroundColor: AppColors.duoGreen,
                            ),
                        );
                    }
                }
            }
        } catch (e) {
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi tải file 3D: $e"), backgroundColor: AppColors.errorRed),
                );
            }
        }
    }

    void _triggerTestViseme(String char, String phoneme) async {
        HapticFeedback.lightImpact();
        setState(() {
            _activeViseme = char;
            _currentEmotion = "talking";
        });
        await _flutterTts.setPitch(_pitch);
        await _flutterTts.setSpeechRate(_speechRate);
        await _flutterTts.speak(phoneme);
    }

    void _triggerTestEmotion(String em) {
        HapticFeedback.mediumImpact();
        setState(() {
            _currentEmotion = em;
        });
    }

    void _testSpeakSample(String text) async {
        HapticFeedback.mediumImpact();
        await _flutterTts.setPitch(_pitch);
        await _flutterTts.setSpeechRate(_speechRate);
        await _flutterTts.speak(text);
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 0,
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.slateGray),
                    onPressed: () => Navigator.pop(context),
                ),
                title: const Row(
                    children: [
                        Icon(Icons.face_retouching_natural, color: AppColors.sakuraPink),
                        SizedBox(width: 8),
                        Text(
                            "3D VTuber Studio (Tiếng Nhật)",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                    ],
                ),
                actions: [
                    TextButton.icon(
                        onPressed: _saveAndSync,
                        icon: const Icon(Icons.sync, color: AppColors.duoGreen, size: 18),
                        label: const Text(
                            "Lưu & Đồng Bộ",
                            style: TextStyle(color: AppColors.duoGreen, fontWeight: FontWeight.bold),
                        ),
                    ),
                    const SizedBox(width: 8),
                ],
            ),
            body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                    children: [
                        // 1. Khung nhìn 3D Viewport lớn
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                color: AppColors.backgroundDark,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: AppColors.sakuraPink.withValues(alpha: 0.4), width: 2),
                                boxShadow: [
                                    BoxShadow(
                                        color: AppColors.sakuraPink.withValues(alpha: 0.15),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                    ),
                                ],
                            ),
                            child: Column(
                                children: [
                                    Avatar3dViewer(
                                        height: 330,
                                        emotion: _currentEmotion,
                                        customAvatarUrl: _avatarUrl,
                                        voiceActorName: _vaName,
                                        isVoiceCloned: true,
                                        onUploadTap: _pickCustom3dFile,
                                    ),
                                    Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.4),
                                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
                                        ),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                                Expanded(
                                                    child: Row(
                                                        children: [
                                                            const Icon(Icons.record_voice_over, color: AppColors.goldAccent, size: 16),
                                                            const SizedBox(width: 6),
                                                            Expanded(
                                                                child: Text(
                                                                    "VA: $_vaName",
                                                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                                                    overflow: TextOverflow.ellipsis,
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                                if (_activeViseme.isNotEmpty)
                                                    Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                        decoration: BoxDecoration(
                                                            color: AppColors.sakuraPink,
                                                            borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Text(
                                                            "Viseme: $_activeViseme",
                                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                                        ),
                                                    ),
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                        ),

                        // 2. Bảng điều khiển Khẩu hình Viseme & Biểu cảm mặt
                        ResponsiveContainer(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    const SizedBox(height: 12),
                                    const Row(
                                        children: [
                                            Icon(Icons.spatial_audio_off, color: AppColors.sakuraPink, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                                "Kiểm Thử Khẩu Hình Âm Vị Tiếng Nhật (Visemes)",
                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slateGray),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                        height: 60,
                                        child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _visemes.length,
                                            separatorBuilder: (ctx, idx) => const SizedBox(width: 10),
                                            itemBuilder: (ctx, idx) {
                                                final v = _visemes[idx];
                                                final isAct = _activeViseme == v["char"];
                                                return InkWell(
                                                    onTap: () => _triggerTestViseme(v["char"]!, v["phoneme"]!),
                                                    borderRadius: BorderRadius.circular(16),
                                                    child: AnimatedContainer(
                                                        duration: const Duration(milliseconds: 200),
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        decoration: BoxDecoration(
                                                            color: isAct ? AppColors.sakuraPink : Theme.of(context).cardColor,
                                                            borderRadius: BorderRadius.circular(16),
                                                            border: Border.all(
                                                                color: isAct ? AppColors.sakuraPink : AppColors.slateGray.withValues(alpha: 0.25),
                                                                width: 2,
                                                            ),
                                                            boxShadow: isAct
                                                                ? [BoxShadow(color: AppColors.sakuraPink.withValues(alpha: 0.4), blurRadius: 8)]
                                                                : [],
                                                        ),
                                                        child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                                Text(
                                                                    v["char"]!,
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 14,
                                                                        color: isAct ? Colors.white : null,
                                                                    ),
                                                                ),
                                                                Text(
                                                                    v["desc"]!,
                                                                    style: TextStyle(
                                                                        fontSize: 10,
                                                                        color: isAct ? Colors.white.withValues(alpha: 0.9) : AppColors.slateGray,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                );
                                            },
                                        ),
                                    ),

                                    const SizedBox(height: 16),
                                    const Row(
                                        children: [
                                            Icon(Icons.emoji_emotions_outlined, color: AppColors.warningOrange, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                                "Kiểm Thử Biểu Cảm Khuôn Mặt (3D Emotions)",
                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slateGray),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                        children: [
                                            _buildEmotionChip("Vui Mừng (Happy)", "happy", Icons.celebration, AppColors.sakuraPink),
                                            const SizedBox(width: 8),
                                            _buildEmotionChip("Suy Nghĩ (Thinking)", "thinking", Icons.psychology, AppColors.warningOrange),
                                            const SizedBox(width: 8),
                                            _buildEmotionChip("Nói Chuyện (Wave)", "talking", Icons.record_voice_over, AppColors.duoGreen),
                                            const SizedBox(width: 8),
                                            _buildEmotionChip("Trở Về (Idle)", "idle", Icons.pause_circle_outline, AppColors.slateGray),
                                        ],
                                    ),

                                    const Divider(height: 36, thickness: 1.5),

                                    // 3. Cấu hình Giọng lồng tiếng & Pitch
                                    const Row(
                                        children: [
                                            Icon(Icons.mic_external_on, color: AppColors.duoBlue, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                                "Hồ Sơ Giọng Lồng Tiếng (Anime VA Voice Profile)",
                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slateGray),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 12),
                                    ..._voiceProfiles.map((vp) => _buildVoiceProfileCard(vp)),

                                    const SizedBox(height: 16),
                                    _buildSliderSection(
                                        "Tốc độ phát âm (Speech Rate)",
                                        "${_speechRate.toStringAsFixed(2)}x",
                                        _speechRate,
                                        0.3,
                                        1.2,
                                        (val) => setState(() => _speechRate = val),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSliderSection(
                                        "Cao độ âm thanh (Pitch Accent)",
                                        _pitch.toStringAsFixed(2),
                                        _pitch,
                                        0.7,
                                        1.5,
                                        (val) => setState(() => _pitch = val),
                                    ),

                                    const SizedBox(height: 24),
                                    SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton.icon(
                                            onPressed: _isSpeaking
                                                ? null
                                                : () {
                                                    final activeProfile = _voiceProfiles.firstWhere(
                                                        (p) => p["id"] == _speakerId,
                                                        orElse: () => _voiceProfiles.first,
                                                    );
                                                    _testSpeakSample(activeProfile["sample"]);
                                                },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.duoGreen,
                                                foregroundColor: Colors.white,
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            ),
                                            icon: _isSpeaking
                                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                : const Icon(Icons.volume_up, size: 22),
                                            label: const Text(
                                                "🔊 Nghe Thử Câu Mẫu Tiếng Nhật Kèm Lip-Sync",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                        ),
                                    ),
                                    const SizedBox(height: 36),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    Widget _buildEmotionChip(String label, String em, IconData icon, Color color) {
        final isAct = _currentEmotion == em;
        return Expanded(
            child: InkWell(
                onTap: () => _triggerTestEmotion(em),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: isAct ? color : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isAct ? color : AppColors.slateGray.withValues(alpha: 0.25), width: 1.5),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(icon, color: isAct ? Colors.white : color, size: 20),
                            const SizedBox(height: 4),
                            Text(
                                label.split(" ")[0],
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isAct ? Colors.white : null,
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildVoiceProfileCard(Map<String, dynamic> vp) {
        final isSelected = _speakerId == vp["id"];
        return Card(
            color: isSelected ? AppColors.duoGreen.withValues(alpha: 0.12) : Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: isSelected ? AppColors.duoGreen : Colors.transparent, width: 2),
            ),
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: isSelected ? AppColors.duoGreen : AppColors.slateGray.withValues(alpha: 0.15),
                    child: Icon(vp["icon"], color: isSelected ? Colors.white : AppColors.slateGray, size: 24),
                ),
                title: Text(
                    vp["name"],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? AppColors.duoGreen : null),
                ),
                subtitle: Text(vp["style"], style: const TextStyle(fontSize: 12)),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.duoGreen, size: 26)
                    : IconButton(
                        icon: const Icon(Icons.play_circle_fill_outlined, color: AppColors.duoGreen),
                        onPressed: () => _testSpeakSample(vp["sample"]),
                    ),
                onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                        _speakerId = vp["id"];
                        _vaName = vp["name"];
                        _pitch = vp["pitch"];
                        _speechRate = vp["rate"];
                    });
                },
            ),
        );
    }

    Widget _buildSliderSection(String title, String valText, double value, double min, double max, ValueChanged<double> onChanged) {
        return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slateGray.withValues(alpha: 0.15)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: AppColors.duoGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(valText, style: const TextStyle(color: AppColors.duoGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                        ],
                    ),
                    Slider(
                        value: value,
                        min: min,
                        max: max,
                        activeColor: AppColors.duoGreen,
                        inactiveColor: AppColors.slateGray.withValues(alpha: 0.2),
                        onChanged: (val) {
                            HapticFeedback.selectionClick();
                            onChanged(val);
                        },
                    ),
                ],
            ),
        );
    }
}
