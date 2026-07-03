import '../../domain/entities/vocab_item.dart';
import '../datasources/local_vocab_datasource.dart';
import '../datasources/remote_ai_datasource.dart';

class VocabRepositoryImpl {
    final LocalVocabDataSource _localDataSource;
    final RemoteAiDataSource _remoteDataSource;

    VocabRepositoryImpl(this._localDataSource, this._remoteDataSource);

    Future<List<VocabItem>> getVocabularyList({bool forceRefresh = false, int lessonId = 1}) async {
        if (!forceRefresh) {
            final localList = await _localDataSource.getLocalVocab(lessonId: lessonId);
            if (localList.isNotEmpty) {
                return localList;
            }
        }

        try {
            final remoteList = await _remoteDataSource.fetchN5Vocabulary(lessonId: lessonId);
            await _localDataSource.cacheVocabList(remoteList);
            return remoteList;
        } catch (e) {
            // Fallback to local if offline or error
            final localList = await _localDataSource.getLocalVocab(lessonId: lessonId);
            if (localList.isNotEmpty) return localList;
            rethrow;
        }
    }

    Future<void> updateSrsItem(VocabItem item) async {
        await _localDataSource.updateVocabItem(item);
    }
}
