import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../widgets/common/3d_avatar_viewer.dart';
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

        await TtsHelper.speak(
            text,
            lang: targetLang,
            tts: _flutterTts,
            speakerId: _currentSpeakerId,
            audioUrl: audioUrl,
            enableVoiceCloning: _enableVoiceCloning,
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
        return Scaffold(
            appBar: AppBar(
                title: const Text("Sensei 3D Tutor Q&A"),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.palette, color: AppColors.duoGreen),
                        onPressed: _showAvatarAndVoiceSelector,
                        tooltip: "Đổi Avatar & Giọng nói VA",
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

                    return Column(
                        children: [
                            // Top 3D Avatar Viewer (Grok Ani style Showcase Frame with Anime VA Voice Cloning)
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Avatar3dViewer(
                                    emotion: _isSpeaking ? "talking" : (_isListening ? "listening" : emotion),
                                    height: 320,
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

                            // Duolingo-inspired Customization Button
                            Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: ElevatedButton.icon(
                                    onPressed: _showAvatarAndVoiceSelector,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.duoGreen,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            side: const BorderSide(color: AppColors.duoGreenShadow, width: 2),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    icon: const Icon(Icons.auto_awesome, size: 16),
                                    label: Text(
                                        "Đổi Avatar & Giọng VA ($_currentVoiceActor)",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                ),
                            ),

                            // Trò chuyện 100% Tiếng Nhật Mode Switcher
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.duoGreen.withValues(alpha: 0.4)),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Row(
                                        children: [
                                            Expanded(
                                                child: GestureDetector(
                                                    onTap: () {
                                                        setState(() {
                                                            _isJapaneseKaiwaMode = false;
                                                            _moduleContext = "japanese_n5";
                                                        });
                                                    },
                                                    child: Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                                        decoration: BoxDecoration(
                                                            color: !_isJapaneseKaiwaMode ? AppColors.duoGreen : Colors.transparent,
                                                            borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        child: Center(
                                                            child: Text(
                                                                "🇻🇳 Giải Thích N5",
                                                                style: TextStyle(
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: !_isJapaneseKaiwaMode ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            Expanded(
                                                child: GestureDetector(
                                                    onTap: () {
                                                        setState(() {
                                                            _isJapaneseKaiwaMode = true;
                                                            _moduleContext = "japanese_kaiwa";
                                                        });
                                                    },
                                                    child: Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                                        decoration: BoxDecoration(
                                                            color: _isJapaneseKaiwaMode ? AppColors.duoGreen : Colors.transparent,
                                                            borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        child: Center(
                                                            child: Text(
                                                                "🇯🇵 100% Tiếng Nhật",
                                                                style: TextStyle(
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: _isJapaneseKaiwaMode ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
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

                            // Suggested Follow-up Questions Chips
                            if (suggestions.isNotEmpty)
                                SizedBox(
                                    height: 44,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: suggestions.length,
                                        itemBuilder: (context, index) {
                                            return Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: ActionChip(
                                                    avatar: const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.duoGreen),
                                                    label: Text(suggestions[index], style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                                    backgroundColor: Theme.of(context).cardColor,
                                                    onPressed: () {
                                                        context.read<ChatBloc>().add(SendChatMessage(suggestions[index], moduleContext: _moduleContext, speakerId: _currentSpeakerId));
                                                    },
                                                ),
                                            );
                                        },
                                    ),
                                ),
                            const Divider(height: 12),

                            // Messages List
                            Expanded(
                                child: messages.isEmpty
                                    ? Center(
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.slateGray.withValues(alpha: 0.4)),
                                                const SizedBox(height: 12),
                                                const Text("Hãy hỏi bất kỳ thắc mắc nào về ngữ pháp hay từ vựng!", style: TextStyle(color: AppColors.slateGray)),
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
                                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
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
                                                                    color: msg.isUser ? Colors.white : (Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.deepIndigo),
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
                                                                        Text("Đọc bằng giọng AI Voice Clone VA", style: TextStyle(fontSize: 11, color: AppColors.slateGray.withValues(alpha: 0.8))),
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
                                            Text("Đang thu âm giọng nói (Speech-to-Text)...", style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold, fontSize: 13)),
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
                                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15),
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
                                            tooltip: "Nhập bằng giọng nói",
                                        ),
                                        IconButton(
                                            icon: const Icon(Icons.send, color: AppColors.duoGreen),
                                            onPressed: _send,
                                        ),
                                    ],
                                ),
                            ),
                        ],
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
            );
            if (result != null && result.files.single.path != null) {
                String path = result.files.single.path!;
                if (!path.startsWith("file://") && !path.startsWith("http") && !path.startsWith("assets")) {
                    path = "file://$path";
                }
                setState(() {
                    _customAvatarUrl = path;
                    _currentVoiceActor = "Custom Anime VA";
                });
                if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Đã tải file '${result.files.single.name}' lên thành công!"),
                            backgroundColor: AppColors.duoGreen,
                        ),
                    );
                    _speak("Konnichiwa! Mình đã tải mô hình 3D từ máy của bạn thành công. Hãy bắt đầu trò chuyện nhé!");
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
                        const Text("Nhập đường dẫn tĩnh hoặc URL mô hình GLB/VRM tuỳ chỉnh của bạn. Hệ thống sẽ tự động đồng bộ Lip-Sync và Rig xương Humanoid!"),
                        const SizedBox(height: 12),
                        TextField(
                            controller: ctrl,
                            decoration: InputDecoration(
                                hintText: "https://.../my_avatar.glb",
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
