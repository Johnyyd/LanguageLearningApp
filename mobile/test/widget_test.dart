// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:language_learning_app/data/repositories/chat_repository_impl.dart';
import 'package:language_learning_app/main.dart';
import 'package:language_learning_app/data/datasources/local_vocab_datasource.dart';
import 'package:language_learning_app/data/repositories/vocab_repository_impl.dart';
import 'package:language_learning_app/data/repositories/ielts_repository_impl.dart';
import 'package:language_learning_app/data/datasources/remote_ai_datasource.dart';
import 'package:language_learning_app/domain/entities/vocab_item.dart';
import 'package:language_learning_app/domain/entities/ielts_report.dart';
import 'package:language_learning_app/domain/entities/chat_message.dart';

class MockRemoteAiDataSource implements RemoteAiDataSource {
  @override
  Future<List<VocabItem>> fetchN5Vocabulary({int lessonId = 1}) async {
    return [];
  }

  @override
  Future<IeltsReport> evaluateIeltsEssay(
    String promptId,
    String essayText, {
    String inputType = "text",
  }) async {
    return const IeltsReport(
      overallBand: 6.0,
      taskAchievement: 6.0,
      cohesionCoherence: 6.0,
      lexicalResource: 6.0,
      grammaticalAccuracy: 6.0,
      generalComment: '',
      grammarErrors: [],
      lexicalUpgrades: [],
    );
  }

  @override
  Future<ChatMessage> ask3dTutor(
    String message,
    String moduleContext, {
    String speakerId = "sensei_va_01",
  }) async {
    return ChatMessage(
      id: '1',
      text: 'Hello',
      isUser: false,
      timestamp: DateTime.now(),
      suggestedQuestions: const [],
    );
  }
}

void main() {
  testWidgets('LanguageLearningApp renders smoke test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final remoteAiDs = MockRemoteAiDataSource();
    final localVocabDs = LocalVocabDataSource();
    await localVocabDs.init();
    final vocabRepo = VocabRepositoryImpl(localVocabDs, remoteAiDs);
    final ieltsRepo = IeltsRepositoryImpl(remoteAiDs);
    final chatRepo = ChatRepositoryImpl(remoteAiDs);
    await tester.pumpWidget(LanguageLearningApp(
      vocabRepo: vocabRepo,
      ieltsRepo: ieltsRepo,
      chatRepo: chatRepo,
    ));

    // Verify that our LanguageLearningApp widget is built.
    expect(find.byType(LanguageLearningApp), findsOneWidget);
  });
}
