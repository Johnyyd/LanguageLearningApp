import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
    // Backend AI Gateway URL (Adapts automatically to Linux Desktop vs Android Emulator vs Web)
    static String get baseUrl {
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
