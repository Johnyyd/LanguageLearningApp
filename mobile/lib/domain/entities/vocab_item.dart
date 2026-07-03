import 'package:equatable/equatable.dart';

class VocabItem extends Equatable {
    final String id;
    final String character;
    final String romaji;
    final String type; // Hiragana, Katakana, Kanji
    final String meaning;
    final String example;
    final String strokeOrderUrl;
    final int srsInterval; // Days until next review
    final int srsRepetition; // Consecutive successful recalls
    final double srsEfactor; // Easiness factor (Anki/SM-2)
    final DateTime? nextReviewDate;

    const VocabItem({
        required this.id,
        required this.character,
        required this.romaji,
        required this.type,
        required this.meaning,
        required this.example,
        required this.strokeOrderUrl,
        this.srsInterval = 1,
        this.srsRepetition = 0,
        this.srsEfactor = 2.5,
        this.nextReviewDate,
    });

    VocabItem copyWith({
        int? srsInterval,
        int? srsRepetition,
        double? srsEfactor,
        DateTime? nextReviewDate,
    }) {
        return VocabItem(
            id: id,
            character: character,
            romaji: romaji,
            type: type,
            meaning: meaning,
            example: example,
            strokeOrderUrl: strokeOrderUrl,
            srsInterval: srsInterval ?? this.srsInterval,
            srsRepetition: srsRepetition ?? this.srsRepetition,
            srsEfactor: srsEfactor ?? this.srsEfactor,
            nextReviewDate: nextReviewDate ?? this.nextReviewDate,
        );
    }

    @override
    List<Object?> get props => [
        id, character, romaji, type, meaning, example, strokeOrderUrl,
        srsInterval, srsRepetition, srsEfactor, nextReviewDate
    ];
}
