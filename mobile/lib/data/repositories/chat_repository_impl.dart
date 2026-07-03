import '../../domain/entities/chat_message.dart';
import '../datasources/remote_ai_datasource.dart';

class ChatRepositoryImpl {
    final RemoteAiDataSource _remoteDataSource;

    ChatRepositoryImpl(this._remoteDataSource);

    Future<ChatMessage> askTutor(String message, String moduleContext) async {
        return await _remoteDataSource.ask3dTutor(message, moduleContext);
    }
}
