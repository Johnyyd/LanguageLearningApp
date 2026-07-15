import 'dart:convert' show base64Encode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_custom_avatar_studio_screen.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../widgets/common/3d_avatar_viewer.dart';
import '../widgets/common/responsive_container.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/tts_helper.dart';
import '../../core/utils/stt_helper.dart';

class ChatTutorScreen extends StatefulWidget {
    const ChatTutorScreen({super.key});

    @override
    State<ChatTutorScreen> createState() => _ChatTutorScreenState();
}

class _ChatTutorScreenState extends State<ChatTutorScreen> {
    final TextEditingController _msgController = TextEditingController();
    final FlutterTts _flutterTts = FlutterTts();
    String _moduleContext = "japanese_n5";
    bool _isJapaneseKaiwaMode = false;
    bool _isVoiceCallMode = false;
    bool _isSpeaking = false;
    bool _isListening = false;
    String? _lastSpokenMessageId;
    String _currentVoiceActor = "Kana Hanazawa (VA)";
    String _currentSpeakerId = "sensei_va_01";
    String? _customAvatarUrl;
    final bool _enableVoiceCloning = true;

    @override
    void initState() {
        super.initState();
        _initTts();
    }

    void _initTts() async {
        await _loadSenseiSettingsFromPrefs();
        try {
            await _flutterTts.setLanguage("vi-VN");
            await _flutterTts.setSpeechRate(0.5);
            await _flutterTts.setVolume(1.0);
            await _flutterTts.setPitch(1.1);

            _flutterTts.setStartHandler(() {
                if (mounted) {
                    setState(() => _isSpeaking = true);
                    context.read<ChatBloc>().add(const UpdateAvatarEmotion("talking"));
                }
            });

            _flutterTts.setCompletionHandler(() {
                if (mounted) {
                    setState(() => _isSpeaking = false);
                    context.read<ChatBloc>().add(const UpdateAvatarEmotion("happy"));
                }
            });

            _flutterTts.setErrorHandler((msg) {
                if (mounted) {
                    setState(() => _isSpeaking = false);
                    context.read<ChatBloc>().add(const UpdateAvatarEmotion("idle"));
                }
            });
        } catch (e) {
            debugPrint("⚠️ TTS not supported on this platform: $e");
        }
    }

    Future<void> _loadSenseiSettingsFromPrefs() async {
        final prefs = await SharedPreferences.getInstance();
        if (mounted) {
            setState(() {
                final savedUrl = prefs.getString("custom_avatar_url");
                if (savedUrl != null && savedUrl.isNotEmpty) {
                    _customAvatarUrl = savedUrl;
                }
                _currentVoiceActor = prefs.getString("custom_va_name") ?? _currentVoiceActor;
                _currentSpeakerId = prefs.getString("custom_speaker_id") ?? _currentSpeakerId;
            });
            final double rate = prefs.getDouble("custom_tts_speed") ?? 0.5;
            final double pitch = prefs.getDouble("custom_tts_pitch") ?? 1.1;
            await _flutterTts.setSpeechRate(rate);
            await _flutterTts.setPitch(pitch);
        }
    }

    Future<void> _openStudioScreen() async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiCustomAvatarStudioScreen()),
        );
        if (result == true) {
            await _loadSenseiSettingsFromPrefs();
        }
    }


    void _speak(String text, {String? audioUrl}) async {
        if (_isSpeaking) {
            await TtsHelper.stop(_flutterTts);
            if (mounted) {
                setState(() => _isSpeaking = false);
                context.read<ChatBloc>().add(const UpdateAvatarEmotion("happy"));
            }
            return;
        }

        final bool hasJapaneseChars = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]').hasMatch(text);
        final String targetLang = hasJapaneseChars ? "ja-JP" : "vi-VN";

        // Chặn gọi API Voice Cloning đối với câu chào (hoặc thông báo hệ thống) để tránh lãng phí tài nguyên phần cứng & API
        final bool isGreeting = text.trim().toLowerCase().startsWith("konnichiwa");
        final bool useVoiceCloning = _enableVoiceCloning && !isGreeting;
        if (isGreeting) {
            debugPrint("⚡ [ChatTutorScreen] Câu chào phát hiện: bỏ qua gọi API Voice Clone, dùng Device TTS nội bộ.");
        }

        await TtsHelper.speak(
            text,
            lang: targetLang,
            tts: _flutterTts,
            speakerId: _currentSpeakerId,
            audioUrl: audioUrl,
            enableVoiceCloning: useVoiceCloning,
            onStart: () {
                if (mounted) {
                    setState(() => _isSpeaking = true);
                    context.read<ChatBloc>().add(const UpdateAvatarEmotion("talking"));
                }
            },
            onComplete: () {
                if (mounted) {
                    setState(() => _isSpeaking = false);
                    context.read<ChatBloc>().add(const UpdateAvatarEmotion("happy"));
                }
            },
            onError: () {
                if (mounted) {
                    setState(() => _isSpeaking = false);
                    context.read<ChatBloc>().add(const UpdateAvatarEmotion("idle"));
                }
            },
        );
    }

    void _toggleVoiceInput() async {
        if (_isListening) {
            await SttHelper.stopListening();
            if (mounted) {
                setState(() => _isListening = false);
                context.read<ChatBloc>().add(const UpdateAvatarEmotion("idle"));
            }
        } else {
            setState(() => _isListening = true);
            context.read<ChatBloc>().add(const UpdateAvatarEmotion("listening"));
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Đang lắng nghe... Hãy nói câu hỏi của bạn!"),
                    backgroundColor: AppColors.duoGreen,
                    duration: Duration(seconds: 2),
                ),
            );
            
            final success = await SttHelper.startListening(
                onResult: (text, isFinal) {
                    if (mounted) {
                        setState(() {
                            _msgController.text = text;
                        });
                        if (isFinal) {
                            setState(() => _isListening = false);
                            if (_msgController.text.trim().isNotEmpty) {
                                _send();
                            } else {
                                context.read<ChatBloc>().add(const UpdateAvatarEmotion("idle"));
                            }
                        }
                    }
                },
            );

            if (!success && mounted) {
                setState(() => _isListening = false);
                context.read<ChatBloc>().add(const UpdateAvatarEmotion("idle"));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Không thể thu âm hoặc chưa cấp quyền micro!"),
                        backgroundColor: AppColors.duoRed,
                        duration: Duration(seconds: 3),
                    ),
                );
            }
        }
    }

    @override
    void dispose() {
        _msgController.dispose();
        TtsHelper.stop(_flutterTts);
        SttHelper.stopListening();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.deepIndigo;

        return Scaffold(
            appBar: AppBar(
                title: const Text("Sensei 3D Tutor Q&A"),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.palette, color: AppColors.duoGreen),
                        onPressed: _showAvatarAndVoiceSelector,
                        tooltip: "Chọn Nhân Vật & Giọng Đọc AI",
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.duoGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.duoGreen.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Icon(Icons.school, size: 16, color: AppColors.duoGreen),
                                SizedBox(width: 4),
                                Text("Tiếng Nhật N5", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.duoGreen)),
                            ],
                        ),
                    ),
                    const SizedBox(width: 12),
                ],
            ),
            body: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                    if (state is ChatActive && state.messages.isNotEmpty) {
                        final lastMsg = state.messages.last;
                        if (!lastMsg.isUser && !state.isAiThinking && _lastSpokenMessageId != lastMsg.id) {
                            _lastSpokenMessageId = lastMsg.id;
                            // Auto trigger TTS lip-sync animation
                            _speak(lastMsg.text, audioUrl: lastMsg.speechAudioUrl);
                        }
                    }
                },
                builder: (context, state) {
                    if (state is ChatError) {
                        return Center(child: Text(state.error, style: const TextStyle(color: AppColors.errorRed)));
                    }

                    final messages = state is ChatActive ? state.messages : [];
                    final emotion = state is ChatActive ? state.currentAvatarEmotion : "idle";
                    final suggestions = state is ChatActive ? state.currentSuggestions : [];

                    return ResponsiveContainer(
                        child: Column(
                            children: [
                                // Mode Selector: Nhắn tin vs Trò chuyện Giọng nói Trực tiếp
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: AppColors.duoGreen.withValues(alpha: 0.3)),
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: Row(
                                            children: [
                                                Expanded(
                                                    child: GestureDetector(
                                                        onTap: () => setState(() => _isVoiceCallMode = false),
                                                        child: Container(
                                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                                            decoration: BoxDecoration(
                                                                color: !_isVoiceCallMode ? AppColors.duoGreen : Colors.transparent,
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                                    "💬 Hỏi Đáp Văn Bản",
                                                                    style: TextStyle(
                                                                        fontSize: 13,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: !_isVoiceCallMode ? Colors.white : textColor,
                                                                    ),
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                                Expanded(
                                                    child: GestureDetector(
                                                        onTap: () => setState(() => _isVoiceCallMode = true),
                                                        child: Container(
                                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                                            decoration: BoxDecoration(
                                                                color: _isVoiceCallMode ? AppColors.duoGreen : Colors.transparent,
                                                                borderRadius: BorderRadius.circular(16),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                                    "🎙️ Trò Chuyện Giọng Nói",
                                                                    style: TextStyle(
                                                                        fontSize: 13,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: _isVoiceCallMode ? Colors.white : textColor,
                                                                    ),
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ),

                                // Top 3D Avatar Viewer (Enlarged Model Display)
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: Avatar3dViewer(
                                        emotion: _isSpeaking ? "talking" : (_isListening ? "listening" : emotion),
                                        height: _isVoiceCallMode ? 380 : 250,
                                        isVoiceCloned: _enableVoiceCloning,
                                        voiceActorName: _currentVoiceActor,
                                        customAvatarUrl: _customAvatarUrl,
                                        onTap: () => _speak(
                                            _isJapaneseKaiwaMode
                                                ? "こんにちは！私は日本語AIチューターのセンセイです。一緒に楽しく日本語を話しましょう！"
                                                : "Konnichiwa! Mình là Sensei ($_currentVoiceActor) với công nghệ lồng tiếng AI Anime. Bạn hãy đặt câu hỏi nhé!"
                                        ),
                                        onUploadTap: _pickAndUpload3dFile,
                                    ),
                                ),

                                // Compact & Well-Named Action Bar right below the 3D Model
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    child: Row(
                                        children: [
                                            Expanded(
                                                child: ElevatedButton.icon(
                                                    onPressed: _showAvatarAndVoiceSelector,
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppColors.duoGreen.withValues(alpha: 0.12),
                                                        foregroundColor: AppColors.duoGreen,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(14),
                                                            side: BorderSide(color: AppColors.duoGreen.withValues(alpha: 0.4)),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                    ),
                                                    icon: const Icon(Icons.face_retouching_natural, size: 16),
                                                    label: const Text(
                                                        "Chọn Nhân Vật & Giọng AI",
                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                        overflow: TextOverflow.ellipsis,
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                                child: ElevatedButton.icon(
                                                    onPressed: () {
                                                        setState(() {
                                                            _isJapaneseKaiwaMode = !_isJapaneseKaiwaMode;
                                                            _moduleContext = _isJapaneseKaiwaMode ? "japanese_kaiwa" : "japanese_n5";
                                                        });
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor: _isJapaneseKaiwaMode
                                                            ? AppColors.duoGreen
                                                            : Theme.of(context).cardColor,
                                                        foregroundColor: _isJapaneseKaiwaMode ? Colors.white : textColor,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(14),
                                                            side: BorderSide(color: AppColors.duoGreen.withValues(alpha: 0.4)),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                    ),
                                                    icon: Icon(
                                                        _isJapaneseKaiwaMode ? Icons.translate : Icons.language,
                                                        size: 16,
                                                        color: _isJapaneseKaiwaMode ? Colors.white : AppColors.duoGreen,
                                                    ),
                                                    label: Text(
                                                        _isJapaneseKaiwaMode ? "🇯🇵 100% Tiếng Nhật" : "🇻🇳 Việt - Nhật (N5)",
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                        overflow: TextOverflow.ellipsis,
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),

                                // VOICE CALL MODE (Trò chuyện hoàn toàn bằng giọng nói giữa người và AI)
                                if (_isVoiceCallMode)
                                    Expanded(
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                    // Spoken Conversation Transcript Card (Hiển thị lại toàn bộ lời nói của Người dùng và AI)
                                                    Expanded(
                                                        child: Container(
                                                            width: double.infinity,
                                                            padding: const EdgeInsets.all(14),
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(context).cardColor,
                                                                borderRadius: BorderRadius.circular(20),
                                                                border: Border.all(color: AppColors.duoGreen.withValues(alpha: 0.3)),
                                                            ),
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                    Row(
                                                                        children: [
                                                                            const Icon(Icons.record_voice_over, size: 16, color: AppColors.duoGreen),
                                                                            const SizedBox(width: 6),
                                                                            Text(
                                                                                "Nội dung đàm thoại trực tiếp (Bạn & AI):",
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.slateGray.withValues(alpha: 0.9)),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                    const Divider(height: 14),
                                                                    Expanded(
                                                                        child: messages.isEmpty
                                                                            ? const Center(
                                                                                child: Text(
                                                                                    "🎙️ Chế độ Thoại Trực Tiếp\nNhấn nút mic bên dưới và nói chuyện tự nhiên với Sensei!",
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(fontSize: 14, color: AppColors.slateGray, height: 1.5),
                                                                                ),
                                                                            )
                                                                            : ListView.builder(
                                                                                itemCount: messages.length,
                                                                                itemBuilder: (context, index) {
                                                                                    final msg = messages[index];
                                                                                    return Container(
                                                                                        margin: const EdgeInsets.only(bottom: 10),
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                        decoration: BoxDecoration(
                                                                                            color: msg.isUser
                                                                                                ? AppColors.deepIndigo.withValues(alpha: 0.08)
                                                                                                : AppColors.duoGreen.withValues(alpha: 0.08),
                                                                                            borderRadius: BorderRadius.circular(12),
                                                                                            border: Border.all(
                                                                                                color: msg.isUser
                                                                                                    ? AppColors.deepIndigo.withValues(alpha: 0.2)
                                                                                                    : AppColors.duoGreen.withValues(alpha: 0.25),
                                                                                            ),
                                                                                        ),
                                                                                        child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                                Row(
                                                                                                    children: [
                                                                                                        Text(
                                                                                                            msg.isUser ? "🗣️ Bạn nói:" : "🤖 Sensei AI trả lời:",
                                                                                                            style: TextStyle(
                                                                                                                fontSize: 11,
                                                                                                                fontWeight: FontWeight.bold,
                                                                                                                color: msg.isUser ? AppColors.deepIndigo : AppColors.duoGreen,
                                                                                                            ),
                                                                                                        ),
                                                                                                        const Spacer(),
                                                                                                        if (!msg.isUser)
                                                                                                            GestureDetector(
                                                                                                                onTap: () => _speak(msg.text, audioUrl: msg.speechAudioUrl),
                                                                                                                child: const Row(
                                                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                                                    children: [
                                                                                                                        Icon(Icons.volume_up, size: 14, color: AppColors.duoGreen),
                                                                                                                        SizedBox(width: 3),
                                                                                                                        Text("Nghe lại", style: TextStyle(fontSize: 10, color: AppColors.duoGreen, fontWeight: FontWeight.bold)),
                                                                                                                    ],
                                                                                                                ),
                                                                                                            ),
                                                                                                    ],
                                                                                                ),
                                                                                                const SizedBox(height: 4),
                                                                                                Text(
                                                                                                    msg.text,
                                                                                                    style: TextStyle(fontSize: 14, color: textColor, height: 1.35),
                                                                                                ),
                                                                                            ],
                                                                                        ),
                                                                                    );
                                                                                },
                                                                            ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                    ),
                                                    const SizedBox(height: 12),

                                                    // Voice Studio Control Button
                                                    GestureDetector(
                                                        onTap: _toggleVoiceInput,
                                                        child: AnimatedContainer(
                                                            duration: const Duration(milliseconds: 250),
                                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                                            decoration: BoxDecoration(
                                                                color: _isListening
                                                                    ? AppColors.errorRed
                                                                    : (_isSpeaking ? AppColors.duoGreen : AppColors.duoGreen),
                                                                borderRadius: BorderRadius.circular(30),
                                                                boxShadow: [
                                                                    BoxShadow(
                                                                        color: (_isListening ? AppColors.errorRed : AppColors.duoGreen).withValues(alpha: 0.35),
                                                                        blurRadius: 14,
                                                                        offset: const Offset(0, 6),
                                                                    ),
                                                                ],
                                                            ),
                                                            child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                    Icon(
                                                                        _isListening ? Icons.stop_circle : (_isSpeaking ? Icons.volume_up : Icons.mic),
                                                                        color: Colors.white,
                                                                        size: 26,
                                                                    ),
                                                                    const SizedBox(width: 10),
                                                                    Text(
                                                                        _isListening
                                                                            ? "Đang nghe... (Nhấn để gửi)"
                                                                            : (_isSpeaking
                                                                                ? "Sensei đang nói... (Nhấn dừng)"
                                                                                : "Nhấn để nói chuyện với Sensei"),
                                                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                ],
                                            ),
                                        ),
                                    )

                                // TEXT CHAT MODE (Hỏi đáp văn bản)
                                else ...[
                                    // Suggested Follow-up Questions Chips
                                    if (suggestions.isNotEmpty)
                                        SizedBox(
                                            height: 38,
                                            child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                itemCount: suggestions.length,
                                                itemBuilder: (context, index) {
                                                    return Padding(
                                                        padding: const EdgeInsets.only(right: 8),
                                                        child: ActionChip(
                                                            avatar: const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.duoGreen),
                                                            label: Text(suggestions[index], style: TextStyle(fontSize: 12, color: textColor)),
                                                            backgroundColor: Theme.of(context).cardColor,
                                                            onPressed: () {
                                                                context.read<ChatBloc>().add(SendChatMessage(suggestions[index], moduleContext: _moduleContext, speakerId: _currentSpeakerId));
                                                            },
                                                        ),
                                                    );
                                                },
                                            ),
                                        ),

                                    // Messages List
                                    Expanded(
                                        child: messages.isEmpty
                                            ? Center(
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                        Icon(Icons.chat_bubble_outline, size: 44, color: AppColors.slateGray.withValues(alpha: 0.4)),
                                                        const SizedBox(height: 10),
                                                        const Text("Hãy nhập câu hỏi hoặc nhấn biểu tượng micro để nói!", style: TextStyle(color: AppColors.slateGray)),
                                                    ],
                                                ),
                                            )
                                            : ListView.builder(
                                                padding: const EdgeInsets.all(16),
                                                itemCount: messages.length,
                                                itemBuilder: (context, index) {
                                                    final msg = messages[index];
                                                    return Align(
                                                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                                                        child: Container(
                                                            margin: const EdgeInsets.only(bottom: 12),
                                                            padding: const EdgeInsets.all(14),
                                                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                                                            decoration: BoxDecoration(
                                                                color: msg.isUser ? AppColors.deepIndigo : Theme.of(context).cardColor,
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: const Radius.circular(16),
                                                                    topRight: const Radius.circular(16),
                                                                    bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                                                                    bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                                                                ),
                                                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
                                                            ),
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                    Text(
                                                                        msg.text,
                                                                        style: TextStyle(
                                                                            color: msg.isUser ? Colors.white : textColor,
                                                                            fontSize: 15,
                                                                            height: 1.3,
                                                                        ),
                                                                    ),
                                                                    if (!msg.isUser) ...[
                                                                        const SizedBox(height: 8),
                                                                        Row(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                                GestureDetector(
                                                                                    onTap: () => _speak(msg.text, audioUrl: msg.speechAudioUrl),
                                                                                    child: Icon(
                                                                                        _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                                                                                        size: 18,
                                                                                        color: AppColors.duoGreen,
                                                                                    ),
                                                                                ),
                                                                                const SizedBox(width: 4),
                                                                                Text("Nghe lại giọng Sensei AI", style: TextStyle(fontSize: 11, color: AppColors.slateGray.withValues(alpha: 0.8))),
                                                                            ],
                                                                        ),
                                                                    ]
                                                                ],
                                                            ),
                                                        ),
                                                    );
                                                },
                                            ),
                                    ),

                                    // AI Thinking / Listening Indicator
                                    if (state is ChatActive && state.isAiThinking)
                                        const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            child: Row(
                                                children: [
                                                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.duoGreen)),
                                                    SizedBox(width: 10),
                                                    Text("Sensei đang suy nghĩ câu trả lời...", style: TextStyle(color: AppColors.slateGray, fontStyle: FontStyle.italic, fontSize: 13)),
                                                ],
                                            ),
                                        )
                                    else if (_isListening)
                                        const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            child: Row(
                                                children: [
                                                    Icon(Icons.mic, size: 18, color: AppColors.errorRed),
                                                    SizedBox(width: 8),
                                                    Text("Đang thu âm giọng nói...", style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold, fontSize: 13)),
                                                ],
                                            ),
                                        ),

                                    // Message Input Field
                                    Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(color: Theme.of(context).cardColor),
                                        child: Row(
                                            children: [
                                                Expanded(
                                                    child: TextField(
                                                        controller: _msgController,
                                                        style: TextStyle(color: textColor, fontSize: 15),
                                                        decoration: InputDecoration(
                                                            hintText: "Hỏi Sensei (VD: Trợ từ Wa vs Ga?)...",
                                                            hintStyle: const TextStyle(color: AppColors.slateGray),
                                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                                            filled: true,
                                                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                        ),
                                                        onSubmitted: (_) => _send(),
                                                    ),
                                                ),
                                                const SizedBox(width: 4),
                                                IconButton(
                                                    icon: Icon(
                                                        _isListening ? Icons.mic : Icons.mic_none,
                                                        color: _isListening ? AppColors.errorRed : AppColors.slateGray,
                                                    ),
                                                    onPressed: _toggleVoiceInput,
                                                    tooltip: "Nói trực tiếp",
                                                ),
                                                IconButton(
                                                    icon: const Icon(Icons.send, color: AppColors.duoGreen),
                                                    onPressed: _send,
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
        );
    }

    void _send() {
        if (_msgController.text.trim().isNotEmpty) {
            if (_isListening) {
                SttHelper.stopListening();
                setState(() => _isListening = false);
            }
            context.read<ChatBloc>().add(SendChatMessage(_msgController.text.trim(), moduleContext: _moduleContext, speakerId: _currentSpeakerId));
            _msgController.clear();
        }
    }

    void _showAvatarAndVoiceSelector() {
        showModalBottomSheet(
            context: context,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (ctx) {
                return StatefulBuilder(
                    builder: (context, setModalState) {
                        return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    const Row(
                                        children: [
                                            Icon(Icons.auto_awesome, color: AppColors.duoGreen),
                                            SizedBox(width: 8),
                                            Text(
                                                "Cấu hình 3D Avatar & Giọng VA",
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text("Chọn nhân vật & giọng đọc AI:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.slateGray)),
                                    const SizedBox(height: 10),
                                    Flexible(
                                        child: SingleChildScrollView(
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                    // Nút nổi bật mở phòng Studio 3D VTuber
                                                    Container(
                                                        width: double.infinity,
                                                        margin: const EdgeInsets.only(bottom: 14),
                                                        child: ElevatedButton.icon(
                                                            onPressed: () {
                                                                Navigator.pop(ctx);
                                                                _openStudioScreen();
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                                backgroundColor: AppColors.sakuraPink,
                                                                foregroundColor: Colors.white,
                                                                elevation: 4,
                                                                shadowColor: AppColors.sakuraPink.withValues(alpha: 0.5),
                                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                            ),
                                                            icon: const Icon(Icons.spatial_audio_off, size: 20),
                                                            label: const Text(
                                                                "🚀 Mở Studio 3D VTuber Toàn Màn Hình",
                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                            ),
                                                        ),
                                                    ),
                                                    _buildPresetOption(
                                                        "Sensei Sakura (Nữ dịu dàng)",
                                                        "Kana Hanazawa (VA)",
                                                        "sensei_va_01",
                                                        null,
                                                        ctx,
                                                    ),
                                                    _buildPresetOption(
                                                        "Zero Two (Darling in the Franxx)",
                                                        "Haruka Tomatsu (VA)",
                                                        "sensei_va_04",
                                                        "assets/models/zero_two/scene.gltf",
                                                        ctx,
                                                    ),
                                                    _buildPresetOption(
                                                        "Sensei Kenji (Nam nhiệt huyết)",
                                                        "Yuki Kaji (VA)",
                                                        "sensei_va_02",
                                                        "https://models.readyplayer.me/648a0422c53f31f93f538e12.glb",
                                                        ctx,
                                                    ),
                                                    _buildPresetOption(
                                                        "Chibi Aoi (Loli nhí nhảnh)",
                                                        "Rie Takahashi (VA)",
                                                        "sensei_va_03",
                                                        "https://models.readyplayer.me/648a0512c53f31f93f538e15.glb",
                                                        ctx,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    const Divider(),
                                                    const SizedBox(height: 12),
                                                    ListTile(
                                                        leading: const CircleAvatar(backgroundColor: AppColors.deepIndigo, child: Icon(Icons.folder_open, color: Colors.white)),
                                                        title: const Text("Tải file mô hình 3D (.VRM/.GLB) từ máy", style: TextStyle(fontWeight: FontWeight.bold)),
                                                        subtitle: const Text("Tự động nhận diện xương (Auto-Rigging) & đồng bộ Lip-Sync", style: TextStyle(fontSize: 12)),
                                                        onTap: () {
                                                            Navigator.pop(ctx);
                                                            _pickAndUpload3dFile();
                                                        },
                                                    ),
                                                    ListTile(
                                                        leading: const CircleAvatar(backgroundColor: AppColors.slateGray, child: Icon(Icons.link, color: Colors.white)),
                                                        title: const Text("Hoặc nhập URL mô hình trực tuyến", style: TextStyle(fontWeight: FontWeight.bold)),
                                                        subtitle: const Text("Dành cho các file lưu trên Server/Cloud", style: TextStyle(fontSize: 12)),
                                                        onTap: () {
                                                            Navigator.pop(ctx);
                                                            _showCustomModelUploadDialog();
                                                        },
                                                    ),
                                                    const SizedBox(height: 10),
                                                ],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        );
                    },
                );
            },
        );
    }

    Widget _buildPresetOption(String title, String vaName, String speakerId, String? modelUrl, BuildContext ctx) {
        final isSelected = _currentSpeakerId == speakerId && _customAvatarUrl == modelUrl;
        return Card(
            color: isSelected ? AppColors.duoGreen.withValues(alpha: 0.15) : Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? AppColors.duoGreen : Colors.transparent, width: 2),
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: isSelected ? AppColors.duoGreen : AppColors.slateGray.withValues(alpha: 0.2),
                    child: Icon(Icons.person, color: isSelected ? Colors.white : AppColors.slateGray),
                ),
                title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppColors.duoGreen : null)),
                subtitle: Text("VA: $vaName", style: const TextStyle(fontSize: 12)),
                trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.duoGreen) : null,
                onTap: () {
                    setState(() {
                        _currentSpeakerId = speakerId;
                        _currentVoiceActor = vaName;
                        _customAvatarUrl = modelUrl;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Đã chuyển sang $title ($vaName)!"), backgroundColor: AppColors.duoGreen),
                    );
                    _speak("Konnichiwa! Mình là $title với chất giọng lồng tiếng của $vaName. Hãy cùng học tiếng Nhật nhé!");
                },
            ),
        );
    }

    Future<void> _pickAndUpload3dFile() async {
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
                    } else if (file.name.toLowerCase().endsWith('.vrm')) {
                        targetUrl = 'data:application/octet-stream;base64,$base64Str';
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
                    final isVrm = file.name.toLowerCase().endsWith('.vrm');
                    setState(() {
                        _customAvatarUrl = targetUrl;
                        _currentVoiceActor = isVrm ? "VRM Anime VA (${file.name})" : "Custom Anime VA (${file.name})";
                    });
                    if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(isVrm
                                    ? "🌟 Đã nạp chuẩn VRM '${file.name}'! (UniVRM Lip-sync & Blendshapes sẵn sàng)"
                                    : "⚡ Đã tải file GLB '${file.name}'! (Hỗ trợ GLTFast Runtime Retargeting)"),
                                backgroundColor: isVrm ? AppColors.sakuraPink : AppColors.duoGreen,
                                duration: const Duration(seconds: 3),
                            ),
                        );
                        _speak(isVrm
                            ? "Konnichiwa! Mình đã tải mô hình chuẩn VRM từ máy của bạn. Khẩu hình và cơ mặt đã được chuẩn hóa!"
                            : "Konnichiwa! Mình đã tải mô hình 3D từ máy của bạn. Hãy bắt đầu đàm thoại nhé!");
                    }
                }
            }
        } catch (e) {
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi tải file: $e"), backgroundColor: AppColors.errorRed),
                );
            }
        }
    }

    void _showCustomModelUploadDialog() {
        final ctrl = TextEditingController(text: _customAvatarUrl ?? "");
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                title: const Text("Nhập URL Avatar (.VRM/.GLB)"),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        const Text(
                            "💡 Khuyến nghị: Sử dụng file chuẩn .vrm (xuất từ VRoid Studio) để có ngay biểu cảm & Lip-sync hoàn hảo qua UniVRM. Hoặc dùng file .glb/URL để tải với GLTFast Retargeting!",
                            style: TextStyle(fontSize: 13, color: AppColors.slateGray),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                            controller: ctrl,
                            decoration: InputDecoration(
                                hintText: "https://.../avatar.vrm hoặc avatar.glb",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                        ),
                    ],
                ),
                actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
                    ElevatedButton(
                        onPressed: () {
                            if (ctrl.text.trim().isNotEmpty) {
                                setState(() {
                                    _customAvatarUrl = ctrl.text.trim();
                                    _currentVoiceActor = "Custom Anime VA";
                                });
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Đã tải URL Avatar tuỳ chỉnh thành công!"), backgroundColor: AppColors.duoGreen),
                                );
                            }
                        },
                        child: const Text("Lưu Mô Hình"),
                    ),
                ],
            ),
        );
    }
}
