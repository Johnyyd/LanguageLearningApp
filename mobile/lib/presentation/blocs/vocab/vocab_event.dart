import 'package:equatable/equatable.dart';
import '../../../../domain/entities/vocab_item.dart';

abstract class VocabEvent extends Equatable {
    const VocabEvent();
    @override
    List<Object?> get props => [];
}

class LoadVocabList extends VocabEvent {
    final bool forceRefresh;
    final int lessonId;
    const LoadVocabList({this.forceRefresh = false, this.lessonId = 1});
    @override
    List<Object?> get props => [forceRefresh, lessonId];
}

class SubmitSrsReview extends VocabEvent {
    final VocabItem item;
    final int quality; // 0 to 5
    const SubmitSrsReview(this.item, this.quality);
    @override
    List<Object?> get props => [item, quality];
}
