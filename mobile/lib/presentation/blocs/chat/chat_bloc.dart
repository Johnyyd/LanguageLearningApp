import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/chat_message.dart';
import '../../../../data/repositories/chat_repository_impl.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
    final ChatRepositoryImpl _repository;

    ChatBloc(this._repository) : super(const ChatActive(messages: [])) {
        on<SendChatMessage>(_onSendMessage);
        on<UpdateAvatarEmotion>(_onUpdateEmotion);
    }

    Future<void> _onSendMessage(SendChatMessage event, Emitter<ChatState> emit) async {
        final currentMessages = state is ChatActive 
            ? (state as ChatActive).messages 
            : <ChatMessage>[];

        final userMsg = ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: event.messageText,
            isUser: true,
            timestamp: DateTime.now(),
        );

        final updatedList = List<ChatMessage>.from(currentMessages)..add(userMsg);
        
        // Show AI thinking animation on 3D Avatar
        emit(ChatActive(
            messages: updatedList,
            isAiThinking: true,
            currentAvatarEmotion: "thinking",
        ));

        try {
            final aiReply = await _repository.askTutor(event.messageText, event.moduleContext, speakerId: event.speakerId);
            final finalList = List<ChatMessage>.from(updatedList)..add(aiReply);
            
            // Switch avatar emotion to reply emotion (happy, explaining, cheering)
            emit(ChatActive(
                messages: finalList,
                isAiThinking: false,
                currentAvatarEmotion: aiReply.avatarEmotion,
                currentSuggestions: aiReply.suggestedQuestions.isNotEmpty 
                    ? aiReply.suggestedQuestions 
                    : ["Làm sao học từ vựng nhanh?", "Phân biệt trợ từ Wa và Ga?"],
            ));
        } catch (e) {
            String errorMsg = "⚠️ Trợ lý AI gặp gián đoạn phản hồi.";
            final errStr = e.toString().toLowerCase();
            if (errStr.contains("timeout") || errStr.contains("timed out")) {
                errorMsg = "⏳ Trợ lý AI đang suy nghĩ phản hồi hoặc server trả lời chậm hơn 120s. Vui lòng thử lại!";
            } else if (errStr.contains("connection") || errStr.contains("socket") || errStr.contains("network") || errStr.contains("refused")) {
                errorMsg = "🌐 Không thể kết nối với Trợ lý AI (127.0.0.1:1112). Vui lòng kiểm tra lại kết nối mạng hoặc AI server!";
            } else {
                errorMsg = "⚠️ Không thể kết nối với Trợ lý AI (${e.toString().split(':').first}).";
            }
            emit(ChatError(errorMsg));
        }
    }

    void _onUpdateEmotion(UpdateAvatarEmotion event, Emitter<ChatState> emit) {
        if (state is ChatActive) {
            final current = state as ChatActive;
            emit(ChatActive(
                messages: current.messages,
                isAiThinking: current.isAiThinking,
                currentAvatarEmotion: event.emotion,
                currentSuggestions: current.currentSuggestions,
            ));
        }
    }
}
