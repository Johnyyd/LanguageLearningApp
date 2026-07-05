// ignore_for_file: file_names
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class Avatar3dViewer extends StatelessWidget {
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

    bool get _isWebViewSupported {
        if (kIsWeb) return true;
        try {
            return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
        } catch (_) {
            return false;
        }
    }

    @override
    Widget build(BuildContext context) {
        final String effectiveModelUrl = (customAvatarUrl != null && customAvatarUrl!.isNotEmpty)
            ? customAvatarUrl!
            : AppConstants.avatar3dUrl;

        return GestureDetector(
            onTap: onTap,
            child: Container(
                height: height,
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
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                        ),
                    ],
                ),
                child: Stack(
                    children: [
                        // Universal 3D Avatar Loader (GLB/VRM or Desktop fallback)
                        ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: _isWebViewSupported
                                ? ModelViewer(
                                    backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                                    src: effectiveModelUrl,
                                    alt: "Grok Ani style 3D Sensei AI Tutor",
                                    ar: false,
                                    autoRotate: emotion == "thinking" || emotion == "idle",
                                    autoPlay: true,
                                    cameraControls: true,
                                    animationName: _getAnimationName(emotion),
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
                                    color: _getBadgeColor(emotion),
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
                                            _getBadgeIcon(emotion),
                                            color: Colors.white,
                                            size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                            _getBadgeText(emotion),
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
                        if (emotion == "talking" || emotion == "thinking")
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
                                                emotion == "talking" ? "Lip-Sync Active" : "AI Reasoning...",
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
                                            isVoiceCloned ? "Sensei (VA: $voiceActorName)" : "Sensei AI (3D Tutor)",
                                            style: const TextStyle(color: Color(0xFF3C3C3C), fontWeight: FontWeight.w600, fontSize: 12),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        // Quick Action: Upload 3D Model File button (Bottom Right)
                        if (onUploadTap != null)
                            Positioned(
                                bottom: 14,
                                right: 14,
                                child: ElevatedButton.icon(
                                    onPressed: onUploadTap,
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
            tween: Tween(begin: 4.0, end: emotion == "talking" ? maxH : 6.0),
            duration: Duration(milliseconds: speedMs),
            curve: Curves.easeInOut,
            builder: (context, val, _) {
                return Container(
                    width: 3,
                    height: val,
                    decoration: BoxDecoration(
                        color: emotion == "talking" ? AppColors.sakuraPink : AppColors.warningOrange,
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
                                            _getBadgeColor(emotion).withValues(alpha: 0.2),
                                            Colors.white,
                                        ],
                                    ),
                                    border: Border.all(
                                        color: _getBadgeColor(emotion),
                                        width: emotion == "talking" || emotion == "thinking" ? 2.5 : 1.5,
                                    ),
                                    boxShadow: [
                                        BoxShadow(
                                            color: _getBadgeColor(emotion).withValues(alpha: 0.4),
                                            blurRadius: emotion == "talking" || emotion == "thinking" ? 16 : 8,
                                            spreadRadius: emotion == "talking" ? 3 : 0,
                                        ),
                                    ],
                                ),
                                child: Icon(
                                    _getBadgeIcon(emotion),
                                    size: 32,
                                    color: _getBadgeColor(emotion),
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
            case "happy":
            case "cheering": return "Jump";
            default: return "Idle";
        }
    }

    Color _getBadgeColor(String em) {
        switch (em) {
            case "talking": return AppColors.successGreen;
            case "thinking": return AppColors.warningOrange;
            case "happy":
            case "cheering": return AppColors.sakuraPink;
            default: return AppColors.slateGray;
        }
    }

    IconData _getBadgeIcon(String em) {
        switch (em) {
            case "talking": return Icons.record_voice_over;
            case "thinking": return Icons.psychology;
            case "happy":
            case "cheering": return Icons.celebration;
            default: return Icons.smart_toy;
        }
    }

    String _getBadgeText(String em) {
        switch (em) {
            case "talking": return isVoiceCloned ? "Anime VA Lip-Sync..." : "Đang nói...";
            case "thinking": return "Đang suy nghĩ...";
            case "happy": return "Vui mừng!";
            case "cheering": return "Tuyệt vời!";
            default: return isVoiceCloned ? "Sẵn sàng (Anime VA)" : "Sẵn sàng";
        }
    }
}
