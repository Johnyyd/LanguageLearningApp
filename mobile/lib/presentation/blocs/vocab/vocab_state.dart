import 'package:equatable/equatable.dart';
import '../../../../domain/entities/vocab_item.dart';

abstract class VocabState extends Equatable {
    const VocabState();
    @override
    List<Object?> get props => [];
}

class VocabInitial extends VocabState {}

class VocabLoading extends VocabState {}

class VocabLoaded extends VocabState {
    final List<VocabItem> vocabList;
    final int streakCount;
    final int lessonId;
    const VocabLoaded(this.vocabList, {this.streakCount = 5, this.lessonId = 1});
    @override
    List<Object?> get props => [vocabList, streakCount, lessonId];
}

class VocabError extends VocabState {
    final String message;
    const VocabError(this.message);
    @override
    List<Object?> get props => [message];
}
