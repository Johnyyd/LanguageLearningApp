import 'package:equatable/equatable.dart';
import '../../../../domain/entities/chat_message.dart';

abstract class ChatState extends Equatable {
    const ChatState();
    @override
    List<Object?> get props => [];
}

class ChatInitial extends ChatState {
    final List<ChatMessage> messages;
    final String currentAvatarEmotion;
    const ChatInitial({this.messages = const [], this.currentAvatarEmotion = "idle"});
    @override
    List<Object?> get props => [messages, currentAvatarEmotion];
}

class ChatActive extends ChatState {
    final List<ChatMessage> messages;
    final bool isAiThinking;
    final String currentAvatarEmotion;
    final List<String> currentSuggestions;

    const ChatActive({
        required this.messages,
        this.isAiThinking = false,
        this.currentAvatarEmotion = "idle",
        this.currentSuggestions = const ["Làm sao nhớ trợ từ Ni và De?", "Cách nhớ Kanji hiệu quả?"],
    });

    @override
    List<Object?> get props => [messages, isAiThinking, currentAvatarEmotion, currentSuggestions];
}

class ChatError extends ChatState {
    final String error;
    const ChatError(this.error);
    @override
    List<Object?> get props => [error];
}
