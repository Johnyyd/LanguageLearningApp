import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../widgets/common/3d_avatar_viewer.dart';
import '../../core/theme/app_theme.dart';

class ChatTutorScreen extends StatefulWidget {
    const ChatTutorScreen({super.key});

    @override
    State<ChatTutorScreen> createState() => _ChatTutorScreenState();
}

class _ChatTutorScreenState extends State<ChatTutorScreen> {
    final TextEditingController _msgController = TextEditingController();
    final FlutterTts _flutterTts = FlutterTts();
    final String _moduleContext = "japanese_n5";
    bool _isSpeaking = false;
    bool _isListening = false;
    String? _lastSpokenMessageId;

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

    void _speak(String text) async {
        if (_isSpeaking) {
            try {
                await _flutterTts.stop();
            } catch (e) {
                // Ignore stop error on Linux
            }
            if (mounted) {
                setState(() => _isSpeaking = false);
                context.read<ChatBloc>().add(const UpdateAvatarEmotion("happy"));
            }
            return;
        }

        try {
            await _flutterTts.speak(text);
        } catch (e) {
            debugPrint("⚠️ TTS speak error / fallback: $e");
            // Fallback lip-sync simulation for Linux Desktop / unsupported platforms
            if (mounted) {
                setState(() => _isSpeaking = true);
                context.read<ChatBloc>().add(const UpdateAvatarEmotion("talking"));
                Future.delayed(const Duration(seconds: 3), () {
                    if (mounted && _isSpeaking) {
                        setState(() => _isSpeaking = false);
                        context.read<ChatBloc>().add(const UpdateAvatarEmotion("happy"));
                    }
                });
            }
        }
    }

    void _toggleVoiceInput() async {
        if (_isListening) {
            setState(() => _isListening = false);
            context.read<ChatBloc>().add(const UpdateAvatarEmotion("idle"));
        } else {
            setState(() => _isListening = true);
            context.read<ChatBloc>().add(const UpdateAvatarEmotion("thinking"));
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("🎙️ Đang lắng nghe... Hãy nói câu hỏi của bạn!"),
                    backgroundColor: AppColors.sakuraPink,
                    duration: Duration(seconds: 2),
                ),
            );
            
            // Simulate portfolio voice STT recognition
            Future.delayed(const Duration(seconds: 2), () {
                if (mounted && _isListening) {
                    setState(() {
                        _isListening = false;
                        _msgController.text = "Thầy ơi, giải thích giúp em cách dùng mẫu câu ~te imasu với ạ?";
                    });
                    context.read<ChatBloc>().add(const UpdateAvatarEmotion("happy"));
                }
            });
        }
    }

    @override
    void dispose() {
        _msgController.dispose();
        _flutterTts.stop();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("🤖 Sensei AI 3D Tutor Q&A"),
                actions: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.sakuraPink.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.sakuraPink.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Icon(Icons.school, size: 16, color: AppColors.sakuraPink),
                                SizedBox(width: 4),
                                Text("🎌 Tiếng Nhật N5", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.sakuraPink)),
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
                            _speak(lastMsg.text);
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
                            // Top 3D Avatar Viewer (Animated Sensei AI with Anime VA Voice Cloning)
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Avatar3dViewer(
                                    emotion: _isSpeaking ? "talking" : (_isListening ? "thinking" : emotion),
                                    height: 200,
                                    isVoiceCloned: true,
                                    voiceActorName: "Kana Hanazawa (VA)",
                                    onTap: () => _speak("Konnichiwa! Mình là Sensei với chất giọng lồng tiếng Anime đây. Bạn hãy đặt câu hỏi nhé!"),
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
                                                    avatar: const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.sakuraPink),
                                                    label: Text(suggestions[index], style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                                    backgroundColor: Theme.of(context).cardColor,
                                                    onPressed: () {
                                                        context.read<ChatBloc>().add(SendChatMessage(suggestions[index], moduleContext: _moduleContext));
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
                                                                            onTap: () => _speak(msg.text),
                                                                            child: Icon(
                                                                                _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                                                                                size: 18,
                                                                                color: AppColors.sakuraPink,
                                                                            ),
                                                                        ),
                                                                        const SizedBox(width: 4),
                                                                        Text("Đọc câu trả lời (TTS)", style: TextStyle(fontSize: 11, color: AppColors.slateGray.withValues(alpha: 0.8))),
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
                                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.sakuraPink)),
                                            SizedBox(width: 10),
                                            Text("Sensei AI đang suy nghĩ câu trả lời...", style: TextStyle(color: AppColors.slateGray, fontStyle: FontStyle.italic, fontSize: 13)),
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
                                            Text("🎙️ Đang thu âm giọng nói (Speech-to-Text)...", style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold, fontSize: 13)),
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
                                                    hintText: "Hỏi Sensei AI (VD: Trợ từ Wa vs Ga?)...",
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
                                            icon: const Icon(Icons.send, color: AppColors.sakuraPink),
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
                setState(() => _isListening = false);
            }
            context.read<ChatBloc>().add(SendChatMessage(_msgController.text.trim(), moduleContext: _moduleContext));
            _msgController.clear();
        }
    }
}
