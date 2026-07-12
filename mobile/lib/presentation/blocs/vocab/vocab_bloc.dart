import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/usecases/srs_calculator.dart';
import '../../../../data/repositories/vocab_repository_impl.dart';
import 'vocab_event.dart';
import 'vocab_state.dart';

class VocabBloc extends Bloc<VocabEvent, VocabState> {
    final VocabRepositoryImpl _repository;

    VocabBloc(this._repository) : super(VocabInitial()) {
        on<LoadVocabList>(_onLoadVocabList);
        on<SubmitSrsReview>(_onSubmitSrsReview);
    }

    Future<void> _onLoadVocabList(LoadVocabList event, Emitter<VocabState> emit) async {
        emit(VocabLoading());
        try {
            final list = await _repository.getVocabularyList(forceRefresh: event.forceRefresh, lessonId: event.lessonId);
            int storedStreak = 1;
            try {
                final prefs = await SharedPreferences.getInstance();
                storedStreak = prefs.getInt('streak_count') ?? 1;
            } catch (_) {}
            emit(VocabLoaded(list, streakCount: storedStreak, lessonId: event.lessonId));
        } catch (e) {
            emit(VocabError("Không thể tải từ vựng N5: $e"));
        }
    }

    Future<void> _onSubmitSrsReview(SubmitSrsReview event, Emitter<VocabState> emit) async {
        if (state is! VocabLoaded) return;
        final currentState = state as VocabLoaded;
        
        // Calculate new SM-2 SRS parameters
        final updatedItem = SrsCalculator.calculateNextReview(event.item, event.quality);
        
        // Save to local & sync
        await _repository.updateSrsItem(updatedItem);
        
        // Update list in state
        final updatedList = currentState.vocabList.map((item) {
            return item.id == updatedItem.id ? updatedItem : item;
        }).toList();
        
        emit(VocabLoaded(updatedList, streakCount: currentState.streakCount, lessonId: currentState.lessonId));
    }
}
