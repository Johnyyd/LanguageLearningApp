import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
    // 🌐 Cấu hình Tailscale Funnel URL cho thiết bị Android thật (Ví dụ: "https://ai-gateway.tailnet-xxx.ts.net")
    // Sau khi chạy backend/setup_tailscale_funnel.sh, dán Public URL vào đây:
    static const String tailscaleFunnelUrl = "https://ai-gateway.taild6d848.ts.net"; 

    // Backend AI Gateway URL (Tự động thích ứng theo Tailscale Funnel > --dart-define > Web > Emulator > Desktop)
    static String get baseUrl {
        // 1. Ưu tiên URL từ command line khi build APK (ví dụ: --dart-define=API_URL=https://...)
        const String envUrl = String.fromEnvironment('API_URL', defaultValue: '');
        if (envUrl.isNotEmpty) {
            return envUrl.endsWith('/') ? "${envUrl}api/v1" : (envUrl.endsWith('/api/v1') ? envUrl : "$envUrl/api/v1");
        }

        // 2. Ưu tiên cấu hình Tailscale Funnel trong code cho thiết bị thật
        if (tailscaleFunnelUrl.isNotEmpty) {
            return tailscaleFunnelUrl.endsWith('/') 
                ? "${tailscaleFunnelUrl}api/v1" 
                : (tailscaleFunnelUrl.endsWith('/api/v1') ? tailscaleFunnelUrl : "$tailscaleFunnelUrl/api/v1");
        }

        // 3. Mặc định cho phát triển cục bộ (Local Development)
        if (kIsWeb) return "http://localhost:1112/api/v1";
        try {
            if (Platform.isAndroid) return "http://10.0.2.2:1112/api/v1";
        } catch (_) {}
        return "http://127.0.0.1:1112/api/v1";
    }
    
    // Module Names
    static const String modJapaneseN5 = "japanese_n5";
    static const String modIeltsWriting = "ielts_writing";
    
    // Storage Keys
    static const String tokenKey = "jwt_access_token";
    static const String usernameKey = "current_username";
    static const String srsBoxName = "srs_vocab_box";
    
    // 3D Model Animations
    static const String animIdle = "idle";
    static const String animTalking = "talking";
    static const String animThinking = "thinking";
    static const String animCheering = "cheering";
    
    // Mock 3D Model GLB Assets (We use ModelViewer with web GLB url or local asset)
    static const String avatar3dUrl = "assets/models/zero_two/scene.gltf";
}
