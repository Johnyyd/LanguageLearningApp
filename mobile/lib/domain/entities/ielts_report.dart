import 'package:equatable/equatable.dart';

class GrammarError extends Equatable {
    final int lineNumber;
    final String original;
    final String corrected;
    final String explanation;

    const GrammarError({
        required this.lineNumber,
        required this.original,
        required this.corrected,
        required this.explanation,
    });

    @override
    List<Object?> get props => [lineNumber, original, corrected, explanation];
}

class LexicalUpgrade extends Equatable {
    final String originalWord;
    final List<String> suggestedAcademicWords;
    final String contextExample;

    const LexicalUpgrade({
        required this.originalWord,
        required this.suggestedAcademicWords,
        required this.contextExample,
    });

    @override
    List<Object?> get props => [originalWord, suggestedAcademicWords, contextExample];
}

class IeltsReport extends Equatable {
    final double overallBand;
    final double taskAchievement;
    final double cohesionCoherence;
    final double lexicalResource;
    final double grammaticalAccuracy;
    final String generalComment;
    final List<GrammarError> grammarErrors;
    final List<LexicalUpgrade> lexicalUpgrades;

    const IeltsReport({
        required this.overallBand,
        required this.taskAchievement,
        required this.cohesionCoherence,
        required this.lexicalResource,
        required this.grammaticalAccuracy,
        required this.generalComment,
        required this.grammarErrors,
        required this.lexicalUpgrades,
    });

    @override
    List<Object?> get props => [
        overallBand, taskAchievement, cohesionCoherence, lexicalResource,
        grammaticalAccuracy, generalComment, grammarErrors, lexicalUpgrades
    ];
}
