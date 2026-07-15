import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Các trạng thái cảm xúc (Emotions) chuẩn hóa cho VTuber 3D Sensei
enum VTuberEmotion {
    idle,
    talking,
    thinking,
    happy,
    listening,
    cheering;

    String get code {
        switch (this) {
            case VTuberEmotion.idle: return "idle";
            case VTuberEmotion.talking: return "talking";
            case VTuberEmotion.thinking: return "thinking";
            case VTuberEmotion.happy: return "happy";
            case VTuberEmotion.listening: return "listening";
            case VTuberEmotion.cheering: return "cheering";
        }
    }

    static VTuberEmotion fromString(String val) {
        switch (val.toLowerCase()) {
            case "talking": return VTuberEmotion.talking;
            case "thinking": return VTuberEmotion.thinking;
            case "happy": return VTuberEmotion.happy;
            case "listening": return VTuberEmotion.listening;
            case "cheering": return VTuberEmotion.cheering;
            default: return VTuberEmotion.idle;
        }
    }
}

/// Các âm vị khẩu hình Lip-sync (Visemes) chuẩn hóa tiếng Nhật
enum VTuberViseme {
    mouthA, // あ
    mouthI, // い
    mouthU, // う
    mouthE, // え
    mouthO, // お
    silence;

    String get code {
        switch (this) {
            case VTuberViseme.mouthA: return "mouth_a";
            case VTuberViseme.mouthI: return "mouth_i";
            case VTuberViseme.mouthU: return "mouth_u";
            case VTuberViseme.mouthE: return "mouth_e";
            case VTuberViseme.mouthO: return "mouth_o";
            case VTuberViseme.silence: return "silence";
        }
    }
}

/// Định dạng file mô hình 3D Custom Avatar
enum AvatarModelFormat {
    vrm,
    glb;

    String get code => this == AvatarModelFormat.vrm ? "vrm" : "glb";
}

/// Luồng xử lý Custom Avatar (VRM Standard vs GLB Auto-Rigging)
enum AvatarModelWorkflow {
    vrmStandard,
    autoRiggedGlb;

    String get code => this == AvatarModelWorkflow.vrmStandard ? "vrm_standard" : "auto_rigged_glb";
}

/// Lớp trừu tượng cho các lệnh gửi từ Flutter sang Unity C#
abstract class UnityCommand {
    String get commandName;
    Map<String, dynamic> toJson();

    String toBridgeString() => jsonEncode(toJson());
}

/// Lệnh chuyển đổi cảm xúc Blendshape
class SetEmotionCommand extends UnityCommand {
    final String emotion;
    final double intensity;
    final double transitionDuration;

    SetEmotionCommand({
        required this.emotion,
        this.intensity = 1.0,
        this.transitionDuration = 0.3,
    });

    @override
    String get commandName => "SetEmotion";

    @override
    Map<String, dynamic> toJson() => {
        "command": commandName,
        "emotion": emotion,
        "intensity": intensity,
        "transitionDuration": transitionDuration,
    };
}

/// Lệnh điều chỉnh khẩu hình Viseme theo thời gian thực (Lip-sync)
class SetVisemeCommand extends UnityCommand {
    final String viseme;
    final double weight;
    final double decayDuration;

    SetVisemeCommand({
        required this.viseme,
        this.weight = 0.85,
        this.decayDuration = 0.15,
    });

    @override
    String get commandName => "SetViseme";

    @override
    Map<String, dynamic> toJson() => {
        "command": commandName,
        "viseme": viseme,
        "weight": weight,
        "decayDuration": decayDuration,
    };
}

/// Lệnh tải hoặc thay thế mô hình 3D (.glb / .vrm) vào Unity Scene
class LoadModelCommand extends UnityCommand {
    final String url;
    final String format;
    final String workflow;
    final bool autoRetarget;
    final bool autoPlay;

    LoadModelCommand({
        required this.url,
        this.format = "glb",
        this.workflow = "auto_rigged_glb",
        this.autoRetarget = true,
        this.autoPlay = true,
    });

    @override
    String get commandName => "LoadModel";

    @override
    Map<String, dynamic> toJson() => {
        "command": commandName,
        "url": url,
        "format": format,
        "workflow": workflow,
        "autoRetarget": autoRetarget,
        "autoPlay": autoPlay,
    };
}

/// Lệnh thay đổi góc máy quay (Camera Preset)
class SetCameraCommand extends UnityCommand {
    final String preset;
    final double smoothTime;

    SetCameraCommand({
        required this.preset,
        this.smoothTime = 0.5,
    });

    @override
    String get commandName => "SetCamera";

    @override
    Map<String, dynamic> toJson() => {
        "command": commandName,
        "preset": preset,
        "smoothTime": smoothTime,
    };
}

/// Dịch vụ trung tâm quản lý giao thức cầu nối Flutter <-> C# Unity
class UnityBridgeService {
    static const String defaultGameObject = "VTuberController";
    static const String defaultMethod = "OnFlutterCommand";

    /// Xử lý tạo lệnh cảm xúc chuẩn hóa JSON
    static String buildEmotionCommand(String emotion, {double intensity = 1.0}) {
        final normalized = VTuberEmotion.fromString(emotion).code;
        return SetEmotionCommand(emotion: normalized, intensity: intensity).toBridgeString();
    }

    /// Xử lý tạo lệnh khẩu hình Viseme JSON
    static String buildVisemeCommand(VTuberViseme viseme, {double weight = 0.85}) {
        return SetVisemeCommand(viseme: viseme.code, weight: weight).toBridgeString();
    }

    /// Xử lý tạo lệnh tải model JSON (hỗ trợ tự động nhận diện VRM / GLB)
    static String buildLoadModelCommand(
        String modelUrl, {
        String? format,
        String? workflow,
        bool autoRetarget = true,
    }) {
        final String effectiveFormat = format ?? detectFormatFromUrl(modelUrl).code;
        final String effectiveWorkflow = workflow ?? (effectiveFormat == "vrm" ? AvatarModelWorkflow.vrmStandard.code : AvatarModelWorkflow.autoRiggedGlb.code);
        return LoadModelCommand(
            url: modelUrl,
            format: effectiveFormat,
            workflow: effectiveWorkflow,
            autoRetarget: autoRetarget,
        ).toBridgeString();
    }

    /// Tự động nhận biết định dạng model (.vrm vs .glb) từ đường dẫn hoặc Data URI
    static AvatarModelFormat detectFormatFromUrl(String url) {
        final lower = url.toLowerCase();
        if (lower.contains(".vrm") || lower.contains("model/vrm") || lower.contains("application/octet-stream")) {
            // Kiểm tra thêm từ tên file nếu là data URI
            if (lower.contains("vrm")) return AvatarModelFormat.vrm;
        }
        return AvatarModelFormat.glb;
    }

    /// Phân tích tin nhắn phản hồi từ Unity C# quay lại Flutter
    static Map<String, dynamic>? parseUnityResponse(dynamic message) {
        if (message == null) return null;
        try {
            if (message is String) {
                return jsonDecode(message) as Map<String, dynamic>;
            }
            if (message is Map<String, dynamic>) {
                return message;
            }
        } catch (e) {
            debugPrint("⚠️ [UnityBridgeService] Lỗi phân tích phản hồi từ Unity: $e");
        }
        return null;
    }
}
