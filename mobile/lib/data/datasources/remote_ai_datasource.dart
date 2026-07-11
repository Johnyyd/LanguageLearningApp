import 'package:flutter/foundation.dart';
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
        try {
            final response = await _apiClient.dio.get('/exercises/n5/grammar');
            return List<Map<String, dynamic>>.from(response.data);
        } catch (e) {
            debugPrint("❌ Error fetching N5 grammar exercises: $e");
            rethrow;
        }
    }

    Future<List<Map<String, dynamic>>> fetchN5Dialogues() async {
        try {
            final response = await _apiClient.dio.get('/exercises/n5/dialogues');
            return List<Map<String, dynamic>>.from(response.data);
        } catch (e) {
            debugPrint("❌ Error fetching N5 dialogues: $e");
            rethrow;
        }
    }

    Future<List<Map<String, dynamic>>> fetchN5MockExamQuestions({String? section}) async {
        try {
            final response = await _apiClient.dio.get(
                '/exercises/n5/mock-exam',
                queryParameters: section != null ? {'section': section} : null,
            );
            return List<Map<String, dynamic>>.from(response.data);
        } catch (e) {
            debugPrint("❌ Error fetching N5 mock exam questions: $e");
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
}
