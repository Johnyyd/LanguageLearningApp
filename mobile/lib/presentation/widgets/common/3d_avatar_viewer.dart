// ignore_for_file: file_names
import 'dart:convert' show base64Encode, jsonDecode, jsonEncode, utf8;
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:model_viewer_plus/model_viewer_plus.dart';
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
    });

    @override
    State<Avatar3dViewer> createState() => _Avatar3dViewerState();
}

class _Avatar3dViewerState extends State<Avatar3dViewer> {
    String? _preparedModelUrl;
    bool _isPreparing = false;
    String _lastInputUrl = "";

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
    }

    @override
    void didUpdateWidget(covariant Avatar3dViewer oldWidget) {
        super.didUpdateWidget(oldWidget);
        final String effectiveUrl = (widget.customAvatarUrl != null && widget.customAvatarUrl!.isNotEmpty)
            ? widget.customAvatarUrl!
            : AppConstants.avatar3dUrl;
        if (effectiveUrl != _lastInputUrl) {
            _prepareModel();
        }
    }

    Future<void> _prepareModel() async {
        final String inputUrl = (widget.customAvatarUrl != null && widget.customAvatarUrl!.isNotEmpty)
            ? widget.customAvatarUrl!
            : AppConstants.avatar3dUrl;
        
        if (inputUrl == _lastInputUrl && _preparedModelUrl != null) return;
        _lastInputUrl = inputUrl;

        // Nếu là URL web hoặc đã là Data URI thì sử dụng trực tiếp
        if (inputUrl.startsWith("http://") || inputUrl.startsWith("https://") || inputUrl.startsWith("data:")) {
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
                } else if (cleanPath.endsWith(".glb")) {
                    final bytes = await rootBundle.load(cleanPath);
                    final base64String = base64Encode(bytes.buffer.asUint8List());
                    resultUrl = 'data:model/gltf-binary;base64,$base64String';
                }
            }
            // 2. Xử lý mô hình từ file cục bộ (khi người dùng upload file từ điện thoại)
            else {
                final file = File(cleanPath);
                if (await file.exists()) {
                    if (cleanPath.endsWith(".glb")) {
                        final bytes = await file.readAsBytes();
                        final base64String = base64Encode(bytes);
                        resultUrl = 'data:model/gltf-binary;base64,$base64String';
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
                        ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: _isPreparing
                                ? const Center(
                                    child: CircularProgressIndicator(color: AppColors.sakuraPink),
                                  )
                                : _isWebViewSupported
                                    ? ModelViewer(
                                        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                                        src: _preparedModelUrl ?? effectiveModelUrl,
                                        alt: "Grok Ani style 3D Sensei AI Tutor",
                                        ar: false,
                                        autoRotate: widget.emotion == "thinking" || widget.emotion == "idle" || widget.emotion == "listening",
                                        autoPlay: true,
                                        cameraControls: true,
                                        animationName: _getAnimationName(widget.emotion),
                                    )
                                    : _buildDesktopFallbackAvatar(effectiveModelUrl),
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
                                style: TextStyle(
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
}
