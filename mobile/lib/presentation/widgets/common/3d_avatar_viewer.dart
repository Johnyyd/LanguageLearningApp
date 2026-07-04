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
    final bool isVoiceCloned;
    final String voiceActorName;

    const Avatar3dViewer({
        super.key,
        this.emotion = "idle",
        this.height = 240,
        this.onTap,
        this.isVoiceCloned = true,
        this.voiceActorName = "Kana Hanazawa (VA)",
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
        return GestureDetector(
            onTap: onTap,
            child: Container(
                height: height,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                            AppColors.deepIndigo.withValues(alpha: 0.9),
                            AppColors.softIndigo.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                        BoxShadow(
                            color: AppColors.deepIndigo.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                        ),
                    ],
                ),
                child: Stack(
                    children: [
                        // Model Viewer Plus for 3D GLB rendering (or Desktop fallback)
                        ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _isWebViewSupported
                                ? ModelViewer(
                                    backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                                    src: AppConstants.avatar3dUrl,
                                    alt: "3D Sensei AI Tutor",
                                    ar: false,
                                    autoRotate: emotion == "thinking" || emotion == "idle",
                                    autoPlay: true,
                                    cameraControls: true,
                                    animationName: _getAnimationName(emotion),
                                )
                                : _buildDesktopFallbackAvatar(),
                        ),
                        // Emotion Badge / Lip-sync indicator
                        Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: _getBadgeColor(emotion),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 4,
                                        )
                                    ],
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        Icon(
                                            _getBadgeIcon(emotion),
                                            color: Colors.white,
                                            size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                            _getBadgeText(emotion),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        // Tutor Name tag
                        Positioned(
                            bottom: 12,
                            left: 16,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                    color: AppColors.deepIndigo.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.sakuraPink.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                    children: [
                                        const Icon(Icons.auto_awesome, color: AppColors.sakuraPink, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                            isVoiceCloned ? "Sensei 3D (🎙️ VA: $voiceActorName)" : "Sensei AI (3D Tutor)",
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
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

    Widget _buildDesktopFallbackAvatar() {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getBadgeColor(emotion).withValues(alpha: 0.25),
                            border: Border.all(
                                color: _getBadgeColor(emotion),
                                width: emotion == "talking" || emotion == "thinking" ? 3 : 1.5,
                            ),
                            boxShadow: [
                                BoxShadow(
                                    color: _getBadgeColor(emotion).withValues(alpha: 0.4),
                                    blurRadius: emotion == "talking" || emotion == "thinking" ? 20 : 10,
                                    spreadRadius: emotion == "talking" ? 4 : 0,
                                ),
                            ],
                        ),
                        child: Icon(
                            _getBadgeIcon(emotion),
                            size: 48,
                            color: Colors.white,
                        ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                        _getBadgeText(emotion),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                        ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        "Sensei AI 3D (Desktop Mode)",
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                        ),
                    ),
                ],
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
            case "talking": return isVoiceCloned ? "🎙️ Anime VA Lip-Sync..." : "Đang nói...";
            case "thinking": return "Đang suy nghĩ...";
            case "happy": return "Vui mừng!";
            case "cheering": return "Tuyệt vời!";
            default: return isVoiceCloned ? "Sẵn sàng (Anime VA)" : "Sẵn sàng";
        }
    }
}
