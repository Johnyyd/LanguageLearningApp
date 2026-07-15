import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_learning_app/core/services/unity_bridge_service.dart';

void main() {
    group('UnityBridgeService Tests', () {
        test('buildEmotionCommand generates correct JSON for happy emotion', () {
            final jsonStr = UnityBridgeService.buildEmotionCommand("happy", intensity: 1.0);
            final map = jsonDecode(jsonStr) as Map<String, dynamic>;

            expect(map['command'], equals('SetEmotion'));
            expect(map['emotion'], equals('happy'));
            expect(map['intensity'], equals(1.0));
            expect(map['transitionDuration'], equals(0.3));
        });

        test('buildEmotionCommand normalizes unknown emotion to idle', () {
            final jsonStr = UnityBridgeService.buildEmotionCommand("unknown_emotion");
            final map = jsonDecode(jsonStr) as Map<String, dynamic>;

            expect(map['emotion'], equals('idle'));
        });

        test('buildVisemeCommand generates correct JSON for mouth_a', () {
            final jsonStr = UnityBridgeService.buildVisemeCommand(VTuberViseme.mouthA, weight: 0.9);
            final map = jsonDecode(jsonStr) as Map<String, dynamic>;

            expect(map['command'], equals('SetViseme'));
            expect(map['viseme'], equals('mouth_a'));
            expect(map['weight'], equals(0.9));
        });

        test('buildLoadModelCommand generates correct JSON for custom glb url', () {
            const testUrl = "data:model/gltf-binary;base64,AAAA";
            final jsonStr = UnityBridgeService.buildLoadModelCommand(testUrl);
            final map = jsonDecode(jsonStr) as Map<String, dynamic>;

            expect(map['command'], equals('LoadModel'));
            expect(map['url'], equals(testUrl));
            expect(map['format'], equals('glb'));
            expect(map['autoPlay'], equals(true));
        });

        test('parseUnityResponse parses JSON strings properly', () {
            const rawResponse = '{"status": "success", "current_emotion": "happy"}';
            final parsed = UnityBridgeService.parseUnityResponse(rawResponse);

            expect(parsed, isNotNull);
            expect(parsed!['status'], equals('success'));
            expect(parsed['current_emotion'], equals('happy'));
        });

        test('parseUnityResponse returns null on invalid input', () {
            expect(UnityBridgeService.parseUnityResponse(null), isNull);
            expect(UnityBridgeService.parseUnityResponse("invalid json string ["), isNull);
        });

        test('detectFormatFromUrl identifies vrm format correctly', () {
            expect(UnityBridgeService.detectFormatFromUrl("https://.../my_avatar.vrm"), equals(AvatarModelFormat.vrm));
            expect(UnityBridgeService.detectFormatFromUrl("data:application/octet-stream;base64,...vrm..."), equals(AvatarModelFormat.vrm));
            expect(UnityBridgeService.detectFormatFromUrl("https://.../my_avatar.glb"), equals(AvatarModelFormat.glb));
        });

        test('buildLoadModelCommand generates correct JSON for vrm workflow', () {
            const testVrmUrl = "data:application/octet-stream;base64,VRM_DATA";
            final jsonStr = UnityBridgeService.buildLoadModelCommand(testVrmUrl, format: "vrm");
            final map = jsonDecode(jsonStr) as Map<String, dynamic>;

            expect(map['command'], equals('LoadModel'));
            expect(map['url'], equals(testVrmUrl));
            expect(map['format'], equals('vrm'));
            expect(map['workflow'], equals('vrm_standard'));
            expect(map['autoRetarget'], equals(true));
        });
    });
}
