// ignore_for_file: file_names
import 'dart:async' show Timer;
import 'dart:convert' show base64Encode, jsonDecode, jsonEncode, utf8;
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter/services.dart' show rootBundle;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart' show WebViewController;
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../../../../core/services/unity_bridge_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class Avatar3dViewer extends StatefulWidget {
    final String emotion; // idle, talking, thinking, happy, cheering
    final double height;
    final VoidCallback? onTap;
    final VoidCallback? onUploadTap;
    final bool isVoiceCloned;
    final String voiceActorName;
    final String? customAvatarUrl;
    final List<Map<String, dynamic>>? visemes;
    final Map<String, dynamic>? rigMetadata;

    const Avatar3dViewer({
        super.key,
        this.emotion = "idle",
        this.height = 320,
        this.onTap,
        this.onUploadTap,
        this.isVoiceCloned = true,
        this.voiceActorName = "Kana Hanazawa (VA)",
        this.customAvatarUrl,
        this.visemes,
        this.rigMetadata,
    });

    @override
    State<Avatar3dViewer> createState() => _Avatar3dViewerState();
}

class _Avatar3dViewerState extends State<Avatar3dViewer> {
    String? _preparedModelUrl;
    bool _isPreparing = false;
    String _lastInputUrl = "";

    // Cầu nối Unity 3D Engine & Trạng thái hoạt động
    UnityWidgetController? _unityController;
    WebViewController? _webViewController;
    Timer? _unityLipSyncTimer;
    final bool _useUnityEngine = !kIsWeb && true; // Sử dụng Unity 3D Engine (Virtual Display / Texture) trên Android/iOS theo yêu cầu để tránh xung đột Semantics của Hybrid Composition WebView

    bool get _isWebViewSupported {
        if (kIsWeb) return true;
        try {
            return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
        } catch (_) {
            return false;
        }
    }

    @override
    void initState() {
        super.initState();
        _prepareModel();
        if (widget.emotion == "talking") {
            _startUnityLipSyncLoop();
        }
    }

    @override
    void dispose() {
        _unityLipSyncTimer?.cancel();
        _unityController?.dispose();
        super.dispose();
    }

    @override
    void didUpdateWidget(covariant Avatar3dViewer oldWidget) {
        super.didUpdateWidget(oldWidget);
        final String effectiveUrl = (widget.customAvatarUrl != null && widget.customAvatarUrl!.isNotEmpty)
            ? widget.customAvatarUrl!
            : AppConstants.avatar3dUrl;
        if (effectiveUrl != _lastInputUrl) {
            _prepareModel();
            if (_unityController != null && widget.customAvatarUrl != null) {
                _sendUnityCommand(UnityBridgeService.buildLoadModelCommand(widget.customAvatarUrl!));
            }
        }

        // Đồng bộ trạng thái cảm xúc (Emotions) & Lip-sync sang Unity Engine / ModelViewer khi thay đổi
        if (widget.emotion != oldWidget.emotion) {
            if (_unityController != null) {
                _sendUnityCommand(UnityBridgeService.buildEmotionCommand(widget.emotion));
                if (widget.emotion == "talking") {
                    _startUnityLipSyncLoop();
                } else {
                    _stopUnityLipSyncLoop();
                }
            }
            if (_webViewController != null) {
                if (widget.emotion == "talking") {
                    _webViewController!.runJavaScript("if (window.SenseiAvatar) window.SenseiAvatar.startSpeaking();");
                } else {
                    _webViewController!.runJavaScript("if (window.SenseiAvatar) window.SenseiAvatar.stopSpeaking();");
                }
            }
        }
    }

    void _startUnityLipSyncLoop() {
        _unityLipSyncTimer?.cancel();
        final visemeSequence = [
            VTuberViseme.mouthA,
            VTuberViseme.mouthE,
            VTuberViseme.mouthI,
            VTuberViseme.mouthO,
            VTuberViseme.mouthU,
        ];
        int idx = 0;
        _unityLipSyncTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
            if (!mounted || widget.emotion != "talking") {
                _stopUnityLipSyncLoop();
                return;
            }
            final vis = visemeSequence[idx % visemeSequence.length];
            _sendUnityCommand(UnityBridgeService.buildVisemeCommand(vis, weight: 0.82));
            idx++;
        });
    }

    void _stopUnityLipSyncLoop() {
        _unityLipSyncTimer?.cancel();
        _unityLipSyncTimer = null;
        if (_unityController != null) {
            _sendUnityCommand(UnityBridgeService.buildVisemeCommand(VTuberViseme.silence, weight: 0.0));
        }
    }

    void _sendUnityCommand(String jsonCommand) {
        if (_unityController != null) {
            try {
                _unityController!.postMessage(
                    UnityBridgeService.defaultGameObject,
                    UnityBridgeService.defaultMethod,
                    jsonCommand,
                );
            } catch (e) {
                debugPrint("⚠️ [UnityBridge] Lỗi gửi tín hiệu sang Unity: $e");
            }
        }
    }

    void _onUnityCreated(UnityWidgetController controller) {
        _unityController = controller;
        // Gửi lệnh cảm xúc khởi tạo ngay sau khi Unity Controller sẵn sàng
        _sendUnityCommand(UnityBridgeService.buildEmotionCommand(widget.emotion));
        if (widget.customAvatarUrl != null && widget.customAvatarUrl!.isNotEmpty) {
            _sendUnityCommand(UnityBridgeService.buildLoadModelCommand(widget.customAvatarUrl!));
        }
    }

    void _onUnityMessage(dynamic message) {
        final parsed = UnityBridgeService.parseUnityResponse(message);
        if (parsed != null) {
            debugPrint("🟢 [UnityBridge] Nhận phản hồi từ VTuber C#: ${parsed['status'] ?? parsed}");
        }
    }

    void _onUnitySceneLoaded(SceneLoaded? scene) {
        debugPrint("🎬 [UnityBridge] Unity Scene đã tải xong: ${scene?.name ?? 'Default'}");
    }

    Future<void> _prepareModel() async {
        final String inputUrl = (widget.customAvatarUrl != null && widget.customAvatarUrl!.isNotEmpty)
            ? widget.customAvatarUrl!
            : AppConstants.avatar3dUrl;
        
        if (inputUrl == _lastInputUrl && _preparedModelUrl != null) return;
        _lastInputUrl = inputUrl;

        // Nếu là URL web, Data URI hoặc Blob URL thì sử dụng trực tiếp
        if (inputUrl.startsWith("http://") || inputUrl.startsWith("https://") || inputUrl.startsWith("data:") || inputUrl.startsWith("blob:")) {
            if (mounted) {
                setState(() {
                    _preparedModelUrl = inputUrl;
                    _isPreparing = false;
                });
            }
            return;
        }

        if (mounted) {
            setState(() {
                _isPreparing = true;
            });
        }

        try {
            String cleanPath = inputUrl.startsWith("file://") ? inputUrl.replaceFirst("file://", "") : inputUrl;
            String resultUrl = inputUrl;

            // 1. Xử lý mô hình từ Assets (Built-in Zero Two hoặc assets khác)
            if (cleanPath.startsWith("assets/")) {
                if (cleanPath.endsWith(".gltf")) {
                    final gltfString = await rootBundle.loadString(cleanPath);
                    final Map<String, dynamic> gltfJson = jsonDecode(gltfString);
                    final baseDir = cleanPath.substring(0, cleanPath.lastIndexOf('/') + 1);

                    // Nhúng buffer geometry (.bin) thành Base64
                    if (gltfJson['buffers'] != null && gltfJson['buffers'] is List) {
                        for (var buffer in gltfJson['buffers']) {
                            final String? uri = buffer['uri'];
                            if (uri != null && !uri.startsWith('data:') && !uri.startsWith('http')) {
                                final binBytes = await rootBundle.load('$baseDir$uri');
                                final base64String = base64Encode(binBytes.buffer.asUint8List());
                                buffer['uri'] = 'data:application/octet-stream;base64,$base64String';
                            }
                        }
                    }

                    // Nhúng texture images (.png/.jpg) thành Base64
                    if (gltfJson['images'] != null && gltfJson['images'] is List) {
                        for (var img in gltfJson['images']) {
                            final String? uri = img['uri'];
                            if (uri != null && !uri.startsWith('data:') && !uri.startsWith('http')) {
                                final imgBytes = await rootBundle.load('$baseDir$uri');
                                final base64String = base64Encode(imgBytes.buffer.asUint8List());
                                String mimeType = 'image/png';
                                if (uri.endsWith('.jpg') || uri.endsWith('.jpeg')) mimeType = 'image/jpeg';
                                img['uri'] = 'data:$mimeType;base64,$base64String';
                            }
                        }
                    }

                    final modifiedGltfString = jsonEncode(gltfJson);
                    final base64Gltf = base64Encode(utf8.encode(modifiedGltfString));
                    resultUrl = 'data:model/gltf+json;base64,$base64Gltf';
                } else if (cleanPath.endsWith(".glb") || cleanPath.endsWith(".vrm")) {
                    final bytes = await rootBundle.load(cleanPath);
                    final base64String = base64Encode(bytes.buffer.asUint8List());
                    final mime = cleanPath.endsWith(".vrm") ? "application/octet-stream" : "model/gltf-binary";
                    resultUrl = 'data:$mime;base64,$base64String';
                }
            }
            // 2. Xử lý mô hình từ file cục bộ (khi người dùng upload file từ điện thoại)
            else if (!kIsWeb) {
                final file = File(cleanPath);
                if (await file.exists()) {
                    if (cleanPath.endsWith(".glb") || cleanPath.endsWith(".vrm")) {
                        final bytes = await file.readAsBytes();
                        final base64String = base64Encode(bytes);
                        final mime = cleanPath.endsWith(".vrm") ? "application/octet-stream" : "model/gltf-binary";
                        resultUrl = 'data:$mime;base64,$base64String';
                    } else if (cleanPath.endsWith(".gltf")) {
                        final gltfString = await file.readAsString();
                        final Map<String, dynamic> gltfJson = jsonDecode(gltfString);
                        final baseDir = file.parent.path;

                        if (gltfJson['buffers'] != null && gltfJson['buffers'] is List) {
                            for (var buffer in gltfJson['buffers']) {
                                final String? uri = buffer['uri'];
                                if (uri != null && !uri.startsWith('data:') && !uri.startsWith('http')) {
                                    final binFile = File('$baseDir/$uri');
                                    if (await binFile.exists()) {
                                        final binBytes = await binFile.readAsBytes();
                                        final base64String = base64Encode(binBytes);
                                        buffer['uri'] = 'data:application/octet-stream;base64,$base64String';
                                    }
                                }
                            }
                        }

                        if (gltfJson['images'] != null && gltfJson['images'] is List) {
                            for (var img in gltfJson['images']) {
                                final String? uri = img['uri'];
                                if (uri != null && !uri.startsWith('data:') && !uri.startsWith('http')) {
                                    final imgFile = File('$baseDir/$uri');
                                    if (await imgFile.exists()) {
                                        final imgBytes = await imgFile.readAsBytes();
                                        final base64String = base64Encode(imgBytes);
                                        String mimeType = 'image/png';
                                        if (uri.endsWith('.jpg') || uri.endsWith('.jpeg')) mimeType = 'image/jpeg';
                                        img['uri'] = 'data:$mimeType;base64,$base64String';
                                    }
                                }
                            }
                        }

                        final modifiedGltfString = jsonEncode(gltfJson);
                        final base64Gltf = base64Encode(utf8.encode(modifiedGltfString));
                        resultUrl = 'data:model/gltf+json;base64,$base64Gltf';
                    } else {
                        final bytes = await file.readAsBytes();
                        final base64String = base64Encode(bytes);
                        resultUrl = 'data:application/octet-stream;base64,$base64String';
                    }
                }
            }

            if (mounted) {
                setState(() {
                    _preparedModelUrl = resultUrl;
                    _isPreparing = false;
                });
            }
        } catch (e) {
            debugPrint("Error preparing 3D model: \$e");
            if (mounted) {
                setState(() {
                    _preparedModelUrl = inputUrl; // Fallback nếu có lỗi
                    _isPreparing = false;
                });
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        final String effectiveModelUrl = (widget.customAvatarUrl != null && widget.customAvatarUrl!.isNotEmpty)
            ? widget.customAvatarUrl!
            : AppConstants.avatar3dUrl;

        return GestureDetector(
            onTap: widget.onTap,
            child: Container(
                height: widget.height,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [
                            Color(0xFFE8F6FF), // Soft Sky Blue
                            Color(0xFFF0F9FF), // Bright White Blue
                            Color(0xFFE6F8E8), // Soft Mint Green
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                    boxShadow: [
                        BoxShadow(
                            color: AppColors.sakuraPink.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                            color: AppColors.deepIndigo.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                        ),
                    ],
                ),
                child: Stack(
                    children: [
                        // Universal 3D Avatar Loader (GLB/VRM or Desktop fallback)
                        Positioned.fill(
                            child: RepaintBoundary(
                                child: SizedBox.expand(
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(26),
                                        child: _isPreparing
                                            ? const Center(
                                                child: CircularProgressIndicator(color: AppColors.sakuraPink),
                                              )
                                            : _useUnityEngine
                                                ? PlatformViewSemanticsCleaner(child: _buildUnityAvatarView())
                                                : _isWebViewSupported
                                                    ? SizedBox.expand(
                                                        child: PlatformViewSemanticsCleaner(
                                                            child: ModelViewer(
                                                                key: ValueKey(_preparedModelUrl ?? effectiveModelUrl),
                                                                id: "sensei-viewer",
                                                                backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                                                                src: _preparedModelUrl ?? effectiveModelUrl,
                                                                alt: "Grok Ani style 3D Sensei AI Tutor",
                                                                ar: false,
                                                                autoRotate: widget.emotion == "thinking" || widget.emotion == "idle" || widget.emotion == "listening",
                                                                autoPlay: true,
                                                                cameraControls: true,
                                                                animationName: _getAnimationName(widget.emotion),
                                                                relatedJs: _getLipSyncJavascript(),
                                                                onWebViewCreated: (controller) {
                                                                    _webViewController = controller;
                                                                    if (widget.emotion == "talking") {
                                                                        Future.delayed(const Duration(milliseconds: 600), () {
                                                                            if (mounted && _webViewController != null && widget.emotion == "talking") {
                                                                                _webViewController!.runJavaScript("if (window.SenseiAvatar) window.SenseiAvatar.startSpeaking();");
                                                                            }
                                                                        });
                                                                    }
                                                                },
                                                            ),
                                                        ),
                                                      )
                                                    : _buildDesktopFallbackAvatar(effectiveModelUrl),
                                    ),
                                ),
                            ),
                        ),
                        // Grok Ani VTuber Mode Header Badge (Top Left)
                        Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                                color: AppColors.successGreen,
                                                shape: BoxShape.circle,
                                            ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                            "GROK ANI COMPANION",
                                            style: TextStyle(color: AppColors.sakuraPink, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        // Emotion Badge / Lip-sync indicator (Top Right)
                        Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: _getBadgeColor(widget.emotion),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 6,
                                        )
                                    ],
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        Icon(
                                            _getBadgeIcon(widget.emotion),
                                            color: Colors.white,
                                            size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                            _getBadgeText(widget.emotion),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        // Real-time Lip-Sync Audio Waveform Indicator when talking
                        if (widget.emotion == "talking" || widget.emotion == "thinking" || widget.emotion == "listening")
                            Positioned(
                                top: 48,
                                left: 16,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
                                    ),
                                    child: Row(
                                        children: [
                                            _buildWaveBar(12, 300),
                                            const SizedBox(width: 3),
                                            _buildWaveBar(18, 200),
                                            const SizedBox(width: 3),
                                            _buildWaveBar(10, 400),
                                            const SizedBox(width: 3),
                                            _buildWaveBar(16, 250),
                                            const SizedBox(width: 6),
                                            Text(
                                                widget.emotion == "talking" ? "Lip-Sync Active" : (widget.emotion == "listening" ? "Đang thu âm..." : "AI Reasoning..."),
                                                style: const TextStyle(color: AppColors.duoGreen, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        // Tutor Name tag (Bottom Left)
                        Positioned(
                            bottom: 14,
                            left: 14,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        const Icon(Icons.auto_awesome, color: AppColors.duoYellow, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                            widget.isVoiceCloned ? "Sensei (VA: ${widget.voiceActorName})" : "Sensei AI (3D Tutor)",
                                            style: const TextStyle(color: Color(0xFF3C3C3C), fontWeight: FontWeight.w600, fontSize: 12),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        // Quick Action: Upload 3D Model File button (Bottom Right)
                        if (widget.onUploadTap != null)
                            Positioned(
                                bottom: 14,
                                right: 14,
                                child: ElevatedButton.icon(
                                    onPressed: widget.onUploadTap,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.sakuraPink,
                                        foregroundColor: Colors.white,
                                        elevation: 6,
                                        shadowColor: AppColors.sakuraPink.withValues(alpha: 0.6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    icon: const Icon(Icons.folder_open, size: 16),
                                    label: const Text("Tải File 3D", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                            ),
                        // AI Rigged Joints Badge (Top Right below Emotion badge)
                        if (widget.rigMetadata != null || (_preparedModelUrl != null && _preparedModelUrl!.contains("gltf-binary")))
                            Positioned(
                                top: 52,
                                right: 16,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            colors: [AppColors.deepIndigo, AppColors.sakuraPink],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                            BoxShadow(
                                                color: AppColors.sakuraPink.withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                            ),
                                        ],
                                    ),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            const Icon(Icons.auto_awesome, color: Colors.white, size: 13),
                                            const SizedBox(width: 5),
                                            Text(
                                                widget.rigMetadata != null
                                                    ? "🌟 AI RIGGED: ${widget.rigMetadata!['skeleton']?['joints_count'] ?? 22} JOINTS (UNITY MECANIM READY)"
                                                    : "⚡ 3D AVATAR READY (MECANIM RETARGETING)",
                                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.4),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                    ],
                ),
            ),
        );
    }

    Widget _buildWaveBar(double maxH, int speedMs) {
        return TweenAnimationBuilder<double>(
            tween: Tween(begin: 4.0, end: widget.emotion == "talking" ? maxH : 6.0),
            duration: Duration(milliseconds: speedMs),
            curve: Curves.easeInOut,
            builder: (context, val, _) {
                return Container(
                    width: 3,
                    height: val,
                    decoration: BoxDecoration(
                        color: widget.emotion == "talking" ? AppColors.sakuraPink : AppColors.warningOrange,
                        borderRadius: BorderRadius.circular(2),
                    ),
                );
            },
        );
    }

    Widget _buildDesktopFallbackAvatar(String modelUrl) {
        final String modelName = modelUrl.split('/').last.replaceAll(RegExp(r'(\?.*|#.*)'), '');
        return Center(
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            // Compact VTuber AI Glowing Avatar Icon
                            AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                        colors: [
                                            _getBadgeColor(widget.emotion).withValues(alpha: 0.2),
                                            Colors.white,
                                        ],
                                    ),
                                    border: Border.all(
                                        color: _getBadgeColor(widget.emotion),
                                        width: widget.emotion == "talking" || widget.emotion == "thinking" || widget.emotion == "listening" ? 2.5 : 1.5,
                                    ),
                                    boxShadow: [
                                        BoxShadow(
                                            color: _getBadgeColor(widget.emotion).withValues(alpha: 0.4),
                                            blurRadius: widget.emotion == "talking" || widget.emotion == "thinking" || widget.emotion == "listening" ? 16 : 8,
                                            spreadRadius: widget.emotion == "talking" ? 3 : 0,
                                        ),
                                    ],
                                ),
                                child: Icon(
                                    _getBadgeIcon(widget.emotion),
                                    size: 32,
                                    color: _getBadgeColor(widget.emotion),
                                ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                "Trợ Lý 3D Sẵn Sàng ($modelName)",
                                style: const TextStyle(
                                    color: AppColors.duoGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget _buildUnityAvatarView() {
        return UnityWidget(
            onUnityCreated: _onUnityCreated,
            onUnityMessage: _onUnityMessage,
            onUnitySceneLoaded: _onUnitySceneLoaded,
            useAndroidViewSurface: false,
            borderRadius: const BorderRadius.all(Radius.circular(26)),
        );
    }

    String _getAnimationName(String em) {
        switch (em) {
            case "talking": return "Wave";
            case "thinking": return "Walking";
            case "listening": return "Idle";
            case "happy":
            case "cheering": return "Jump";
            default: return "Idle";
        }
    }

    Color _getBadgeColor(String em) {
        switch (em) {
            case "talking": return AppColors.successGreen;
            case "thinking": return AppColors.warningOrange;
            case "listening": return AppColors.duoYellow;
            case "happy":
            case "cheering": return AppColors.sakuraPink;
            default: return AppColors.slateGray;
        }
    }

    IconData _getBadgeIcon(String em) {
        switch (em) {
            case "talking": return Icons.record_voice_over;
            case "thinking": return Icons.psychology;
            case "listening": return Icons.mic;
            case "happy":
            case "cheering": return Icons.celebration;
            default: return Icons.smart_toy;
        }
    }

    String _getBadgeText(String em) {
        switch (em) {
            case "talking": return widget.isVoiceCloned ? "Anime VA Lip-Sync..." : "Đang nói...";
            case "thinking": return "Đang suy nghĩ...";
            case "listening": return "Đang thu âm...";
            case "happy": return "Vui mừng!";
            case "cheering": return "Tuyệt vời!";
            default: return widget.isVoiceCloned ? "Sẵn sàng (Anime VA)" : "Sẵn sàng";
        }
    }

    String _getLipSyncJavascript() {
        return '''
window.SenseiAvatar = {
  modelViewer: null,
  isSpeaking: false,
  visemeInterval: null,
  currentViseme: 'silence',
  blendshapeNames: [],
  hasBlendshapes: false,
  headBone: null,
  jawBone: null,
  initialHeadRotX: null,
  initialJawRotX: null,
  
  init: function() {
    this.modelViewer = document.getElementById('sensei-viewer');
    if (!this.modelViewer) return;
    
    const self = this;
    this.modelViewer.addEventListener('load', function() {
      console.log('🟢 [SenseiLipSync] 3D Model loaded into ModelViewer.');
      self.scanBlendshapesAndBones();
    });
  },
  
  getThreeScene: function() {
    if (!this.modelViewer) return null;
    return this.modelViewer[Symbol.for('threeModal')] || 
           this.modelViewer[Symbol.for('scene')] || 
           (this.modelViewer.model && this.modelViewer.model[Symbol.for('scene')]) ||
           this.modelViewer.threeScene;
  },

  scanBlendshapesAndBones: function() {
    if (!this.modelViewer) return;
    try {
      this.blendshapeNames = [];
      if (this.modelViewer.availableMorphTargets && this.modelViewer.availableMorphTargets.length > 0) {
        this.blendshapeNames = [...this.modelViewer.availableMorphTargets];
      }
      
      const scene = this.getThreeScene();
      if (scene && typeof scene.traverse === 'function') {
        scene.traverse(node => {
          if (node.isMesh && node.morphTargetDictionary) {
            Object.keys(node.morphTargetDictionary).forEach(key => {
              if (!this.blendshapeNames.includes(key)) this.blendshapeNames.push(key);
            });
          }
          if (node.isBone || (node.type && node.type.toLowerCase().includes('bone'))) {
            const name = (node.name || '').toLowerCase();
            if (name.includes('jaw') || name.includes('mouth_bone')) {
              this.jawBone = node;
              if (this.initialJawRotX === null) this.initialJawRotX = node.rotation.x;
            } else if (!this.headBone && (name === 'head' || name.endsWith('_head') || name.includes('head_bone'))) {
              this.headBone = node;
              if (this.initialHeadRotX === null) this.initialHeadRotX = node.rotation.x;
            }
          }
        });
      }

      if (typeof this.modelViewer.model?.getMorphTargetNames === 'function') {
        const names = this.modelViewer.model.getMorphTargetNames() || [];
        names.forEach(n => { if (!this.blendshapeNames.includes(n)) this.blendshapeNames.push(n); });
      }

      if (this.blendshapeNames.length > 0) {
        this.hasBlendshapes = true;
        console.log('🟢 [SenseiLipSync] Found blendshapes:', this.blendshapeNames);
      }
      if (this.jawBone || this.headBone) {
        console.log('🟢 [SenseiLipSync] Found bones - Jaw:', !!this.jawBone, 'Head:', !!this.headBone);
      }
    } catch (e) {
      console.log('⚠️ [SenseiLipSync] Error scanning model:', e);
    }
  },

  setViseme: function(visemeCode, weight) {
    if (!this.modelViewer) return;
    this.currentViseme = visemeCode;
    
    const targetAliases = {
      'mouth_a': ['Viseme_A', 'mouth_a', 'jawOpen', 'A', 'vrc.v_aa', 'F_Talking_01', 'mouthOpen', 'Mouth_Open', 'open_mouth'],
      'mouth_i': ['Viseme_I', 'mouth_i', 'I', 'vrc.v_ih', 'smile'],
      'mouth_u': ['Viseme_U', 'mouth_u', 'U', 'vrc.v_ou', 'pout'],
      'mouth_e': ['Viseme_E', 'mouth_e', 'E', 'vrc.v_e'],
      'mouth_o': ['Viseme_O', 'mouth_o', 'O', 'vrc.v_oh', 'surprise'],
      'silence': []
    };
    
    const aliases = targetAliases[visemeCode] || [];
    let applied = false;
    
    // 1. Thử qua API của ModelViewer (nếu hỗ trợ)
    if (typeof this.modelViewer.model?.setMorphTargetInfluence === 'function') {
      for (const key in targetAliases) {
        targetAliases[key].forEach(alias => {
          try { this.modelViewer.model.setMorphTargetInfluence(alias, 0.0); } catch(e){}
        });
      }
      if (visemeCode !== 'silence') {
        for (let i = 0; i < aliases.length; i++) {
          try {
            this.modelViewer.model.setMorphTargetInfluence(aliases[i], weight);
            applied = true;
            break;
          } catch(e){}
        }
      }
    }

    // 2. Thử qua trực tiếp cây Three.js morphTargetInfluences
    const scene = this.getThreeScene();
    if (scene && typeof scene.traverse === 'function') {
      scene.traverse(node => {
        if (node.isMesh && node.morphTargetDictionary && node.morphTargetInfluences) {
          for (const key in targetAliases) {
            targetAliases[key].forEach(alias => {
              if (alias in node.morphTargetDictionary) {
                node.morphTargetInfluences[node.morphTargetDictionary[alias]] = 0.0;
              }
            });
          }
          if (visemeCode !== 'silence') {
            for (let i = 0; i < aliases.length; i++) {
              const alias = aliases[i];
              if (alias in node.morphTargetDictionary) {
                node.morphTargetInfluences[node.morphTargetDictionary[alias]] = weight;
                applied = true;
                break;
              }
            }
          }
        }
      });
    }
    
    // 3. Xử lý xoay xương hàm hoặc đầu nhẹ nhàng nếu không có morph target (loại bỏ hoàn toàn stretch dọc toàn thân scaleY)
    if (!applied && visemeCode !== 'silence') {
      this.applyBoneSpeechMotion(visemeCode, weight);
    } else if (visemeCode === 'silence') {
      this.resetBoneSpeechMotion();
    }
  },
  
  applyBoneSpeechMotion: function(visemeCode, weight) {
    if (this.jawBone && this.initialJawRotX !== null) {
      const angle = (visemeCode === 'mouth_a' ? 0.22 : 0.12) * weight;
      this.jawBone.rotation.x = this.initialJawRotX + angle;
    } else if (this.headBone && this.initialHeadRotX !== null) {
      const nod = (visemeCode === 'mouth_a' ? 0.035 : 0.018) * weight;
      this.headBone.rotation.x = this.initialHeadRotX + nod;
    }
  },
  
  resetBoneSpeechMotion: function() {
    if (this.jawBone && this.initialJawRotX !== null) {
      this.jawBone.rotation.x = this.initialJawRotX;
    }
    if (this.headBone && this.initialHeadRotX !== null) {
      this.headBone.rotation.x = this.initialHeadRotX;
    }
  },

  startSpeaking: function() {
    this.isSpeaking = true;
    const visemeSequence = ['mouth_a', 'mouth_e', 'mouth_i', 'mouth_o', 'mouth_u', 'mouth_a'];
    let idx = 0;
    const self = this;
    if (this.visemeInterval) clearInterval(this.visemeInterval);
    this.visemeInterval = setInterval(function() {
      if (!self.isSpeaking) {
        self.stopSpeaking();
        return;
      }
      const vis = visemeSequence[idx % visemeSequence.length];
      const randomWeight = 0.65 + Math.random() * 0.35;
      self.setViseme(vis, randomWeight);
      idx++;
    }, 150);
  },

  stopSpeaking: function() {
    this.isSpeaking = false;
    if (this.visemeInterval) {
      clearInterval(this.visemeInterval);
      this.visemeInterval = null;
    }
    this.setViseme('silence', 0.0);
  }
};
window.addEventListener('DOMContentLoaded', function() { if (window.SenseiAvatar) window.SenseiAvatar.init(); });
setTimeout(function() { if (window.SenseiAvatar) window.SenseiAvatar.init(); }, 600);
''';
    }
}

/// Utility widget giúp bảo vệ và cách ly PlatformView (AndroidView/WebView/ModelViewer)
/// khỏi lỗi assertion '!semantics.parentDataDirty' khi nhúng bên trong các layout động.
class PlatformViewSemanticsCleaner extends SingleChildRenderObjectWidget {
    const PlatformViewSemanticsCleaner({super.key, required super.child});

    @override
    RenderObject createRenderObject(BuildContext context) => _RenderPlatformViewSemanticsCleaner();
}

class _RenderPlatformViewSemanticsCleaner extends RenderProxyBox {
    _RenderPlatformViewSemanticsCleaner();

    @override
    void describeSemanticsConfiguration(SemanticsConfiguration config) {
        super.describeSemanticsConfiguration(config);
        config.isSemanticBoundary = true;
        config.isBlockingSemanticsOfPreviouslyPaintedNodes = true;
    }
}


