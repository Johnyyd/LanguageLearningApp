import '../../domain/entities/ielts_report.dart';
import '../datasources/remote_ai_datasource.dart';

class IeltsRepositoryImpl {
    final RemoteAiDataSource _remoteDataSource;

    IeltsRepositoryImpl(this._remoteDataSource);

    Future<IeltsReport> evaluateEssay(String promptId, String essayText, {String inputType = "text"}) async {
        return await _remoteDataSource.evaluateIeltsEssay(promptId, essayText, inputType: inputType);
    }
}
