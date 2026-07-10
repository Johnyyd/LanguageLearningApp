import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
    const ChatEvent();
    @override
    List<Object?> get props => [];
}

class SendChatMessage extends ChatEvent {
    final String messageText;
    final String moduleContext;
    final String speakerId;
    const SendChatMessage(this.messageText, {this.moduleContext = "japanese_n5", this.speakerId = "sensei_va_01"});
    @override
    List<Object?> get props => [messageText, moduleContext, speakerId];
}

class UpdateAvatarEmotion extends ChatEvent {
    final String emotion;
    const UpdateAvatarEmotion(this.emotion);
    @override
    List<Object?> get props => [emotion];
}
