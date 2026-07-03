import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
    final String id;
    final String text;
    final bool isUser;
    final String avatarEmotion; // idle, talking, thinking, happy, explaining, cheering
    final DateTime timestamp;
    final List<String> suggestedQuestions;

    const ChatMessage({
        required this.id,
        required this.text,
        required this.isUser,
        this.avatarEmotion = "idle",
        required this.timestamp,
        this.suggestedQuestions = const [],
    });

    @override
    List<Object?> get props => [id, text, isUser, avatarEmotion, timestamp, suggestedQuestions];
}
