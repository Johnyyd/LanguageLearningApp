import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/vocab_item.dart';
import '../../domain/entities/ielts_report.dart';
import '../../domain/entities/chat_message.dart';

class RemoteAiDataSource {
    final ApiClient _apiClient;

    RemoteAiDataSource(this._apiClient);

    Future<List<VocabItem>> fetchN5Vocabulary({int lessonId = 1}) async {
        try {
            final response = await _apiClient.dio.get('/vocab/n5', queryParameters: {'lesson': lessonId});
            final List<dynamic> data = response.data;
            return data.map((e) => VocabItem(
                id: e['id'] ?? 'jap_000',
                character: e['character'] ?? 'あ',
                romaji: e['romaji'] ?? 'a',
                type: e['type'] ?? 'Hiragana',
                meaning: e['meaning'] ?? '',
                example: e['example'] ?? '',
                strokeOrderUrl: e['stroke_order_url'] ?? '',
                srsInterval: e['srs_interval'] ?? 1,
                srsRepetition: e['srs_repetition'] ?? 0,
                srsEfactor: (e['srs_efactor'] ?? 2.5).toDouble(),
            )).toList();
        } catch (e) {
            debugPrint("❌ Error fetching remote N5 vocabulary: $e");
            rethrow;
        }
    }

    Future<IeltsReport> evaluateIeltsEssay(String promptId, String essayText, {String inputType = "text"}) async {
        try {
            final response = await _apiClient.dio.post('/ielts/evaluate', data: {
                "prompt_id": promptId,
                "input_type": inputType,
                "essay_text": essayText,
            });
            
            final rep = response.data['report'];
            final sub = rep['sub_scores'] ?? {};
            
            final List<dynamic> rawErr = rep['grammar_errors'] ?? [];
            final grammarErrors = rawErr.map((g) => GrammarError(
                lineNumber: g['line_number'] ?? 1,
                original: g['original'] ?? '',
                corrected: g['corrected'] ?? '',
                explanation: g['explanation'] ?? '',
            )).toList();
            
            final List<dynamic> rawLex = rep['lexical_upgrades'] ?? [];
            final lexicalUpgrades = rawLex.map((l) => LexicalUpgrade(
                originalWord: l['original_word'] ?? '',
                suggestedAcademicWords: List<String>.from(l['suggested_academic_words'] ?? []),
                contextExample: l['context_example'] ?? '',
            )).toList();

            return IeltsReport(
                overallBand: (rep['overall_band'] ?? 6.0).toDouble(),
                taskAchievement: (sub['task_achievement'] ?? 6.0).toDouble(),
                cohesionCoherence: (sub['cohesion_coherence'] ?? 6.0).toDouble(),
                lexicalResource: (sub['lexical_resource'] ?? 6.0).toDouble(),
                grammaticalAccuracy: (sub['grammatical_accuracy'] ?? 6.0).toDouble(),
                generalComment: rep['general_comment'] ?? '',
                grammarErrors: grammarErrors,
                lexicalUpgrades: lexicalUpgrades,
            );
        } catch (e) {
            debugPrint("❌ Error evaluating IELTS essay: $e");
            rethrow;
        }
    }

    Future<ChatMessage> ask3dTutor(String message, String moduleContext, {String speakerId = "sensei_va_01"}) async {
        try {
            final response = await _apiClient.dio.post('/chat/ask', data: {
                "message": message,
                "module_context": moduleContext,
                "speaker_id": speakerId,
            });
            
            final data = response.data;
            return ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text: data['reply_text'] ?? "Xin chào, tôi là Sensei AI!",
                isUser: false,
                avatarEmotion: data['avatar_emotion'] ?? "happy",
                speechAudioUrl: data['speech_audio_url'],
                timestamp: DateTime.now(),
                suggestedQuestions: List<String>.from(data['suggested_questions'] ?? []),
            );
        } catch (e) {
            debugPrint("❌ Error asking 3D tutor: $e");
            rethrow;
        }
    }

    Future<List<Map<String, dynamic>>> fetchN5GrammarExercises() async {
        const cacheKey = 'api_cache_n5_grammar_exercises';
        try {
            final response = await _apiClient.dio.get('/exercises/n5/grammar');
            final data = List<Map<String, dynamic>>.from(response.data);
            try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(cacheKey, jsonEncode(data));
            } catch (_) {}
            return data;
        } catch (e) {
            debugPrint("❌ Error fetching N5 grammar exercises, attempting cache load: $e");
            try {
                final prefs = await SharedPreferences.getInstance();
                final cachedStr = prefs.getString(cacheKey);
                if (cachedStr != null) {
                    final List<dynamic> decoded = jsonDecode(cachedStr);
                    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
                }
            } catch (_) {}
            rethrow;
        }
    }

    Future<List<Map<String, dynamic>>> fetchN5Dialogues() async {
        const cacheKey = 'api_cache_n5_dialogues';
        try {
            final response = await _apiClient.dio.get('/exercises/n5/dialogues');
            final data = List<Map<String, dynamic>>.from(response.data);
            try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(cacheKey, jsonEncode(data));
            } catch (_) {}
            return data;
        } catch (e) {
            debugPrint("❌ Error fetching N5 dialogues, attempting cache load: $e");
            try {
                final prefs = await SharedPreferences.getInstance();
                final cachedStr = prefs.getString(cacheKey);
                if (cachedStr != null) {
                    final List<dynamic> decoded = jsonDecode(cachedStr);
                    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
                }
            } catch (_) {}
            rethrow;
        }
    }

    Future<List<Map<String, dynamic>>> fetchN5MockExamQuestions({String? section}) async {
        final cacheKey = 'api_cache_n5_mock_exam_${section ?? "all"}';
        try {
            final response = await _apiClient.dio.get(
                '/exercises/n5/mock-exam',
                queryParameters: section != null ? {'section': section} : null,
            );
            final data = List<Map<String, dynamic>>.from(response.data);
            try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(cacheKey, jsonEncode(data));
            } catch (_) {}
            return data;
        } catch (e) {
            debugPrint("❌ Error fetching N5 mock exam questions, attempting cache load: $e");
            try {
                final prefs = await SharedPreferences.getInstance();
                final cachedStr = prefs.getString(cacheKey);
                if (cachedStr != null) {
                    final List<dynamic> decoded = jsonDecode(cachedStr);
                    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
                }
            } catch (_) {}
            rethrow;
        }
    }

    Future<List<Map<String, dynamic>>> fetchIeltsPrompts() async {
        try {
            final response = await _apiClient.dio.get('/exercises/ielts/prompts');
            return List<Map<String, dynamic>>.from(response.data);
        } catch (e) {
            debugPrint("❌ Error fetching IELTS prompts: $e");
            rethrow;
        }
    }

    Future<Map<String, dynamic>> registerUser({required String username, required String email, required String password, String? fullName}) async {
        try {
            final response = await _apiClient.dio.post('/auth/register', data: {
                "username": username,
                "email": email,
                "password": password,
                "full_name": fullName ?? username,
            });
            final data = Map<String, dynamic>.from(response.data);
            try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('auth_token', data['access_token'] ?? '');
                await prefs.setString('auth_username', data['username'] ?? username);
                await prefs.setInt('streak_count', data['effective_streak'] ?? data['streak_count'] ?? 1);
                await prefs.setString('last_activity_date', data['last_activity_date'] ?? '');
            } catch (_) {}
            return data;
        } catch (e) {
            debugPrint("Error registering user: $e");
            rethrow;
        }
    }

    Future<Map<String, dynamic>> loginUser({required String username, required String password}) async {
        try {
            final response = await _apiClient.dio.post('/auth/login', data: {
                "username": username,
                "password": password,
            });
            final data = Map<String, dynamic>.from(response.data);
            try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('auth_token', data['access_token'] ?? '');
                await prefs.setString('auth_username', data['username'] ?? username);
                await prefs.setInt('streak_count', data['effective_streak'] ?? data['streak_count'] ?? 0);
                await prefs.setString('last_activity_date', data['last_activity_date'] ?? '');
            } catch (_) {}
            return data;
        } catch (e) {
            debugPrint("Error logging in: $e");
            rethrow;
        }
    }

    Future<Map<String, dynamic>> recordUserActivity({required String username, String? activityDate}) async {
        try {
            final response = await _apiClient.dio.post('/auth/activity', data: {
                "username": username,
                "activity_date": activityDate,
            });
            final data = Map<String, dynamic>.from(response.data);
            try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('streak_count', data['effective_streak'] ?? data['streak_count'] ?? 1);
                await prefs.setString('last_activity_date', data['last_activity_date'] ?? '');
            } catch (_) {}
            return data;
        } catch (e) {
            debugPrint("Error recording activity: $e");
            rethrow;
        }
    }
}
