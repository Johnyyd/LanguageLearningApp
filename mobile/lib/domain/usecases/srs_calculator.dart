import '../entities/vocab_item.dart';

class SrsCalculator {
    /// Evaluates recall quality (0 to 5) and updates SRS parameters using SuperMemo-2 algorithm.
    /// Quality rating:
    /// 0 - Complete blackout
    /// 1 - Incorrect response, upon seeing correct answer it felt familiar
    /// 2 - Incorrect response, but correct answer seemed easy to remember
    /// 3 - Correct response recalled with serious difficulty
    /// 4 - Correct response after a hesitation
    /// 5 - Perfect, instant recall
    static VocabItem calculateNextReview(VocabItem item, int quality) {
        if (quality < 0 || quality > 5) {
            quality = 3; // Default fallback
        }

        int newInterval;
        int newRepetition;
        double newEfactor = item.srsEfactor;

        if (quality >= 3) {
            // Correct recall
            if (item.srsRepetition == 0) {
                newInterval = 1;
            } else if (item.srsRepetition == 1) {
                newInterval = 6;
            } else {
                newInterval = (item.srsInterval * item.srsEfactor).round();
            }
            newRepetition = item.srsRepetition + 1;
        } else {
            // Incorrect recall - reset repetition and interval
            newRepetition = 0;
            newInterval = 1;
        }

        // Update E-Factor: EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        newEfactor = item.srsEfactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
        if (newEfactor < 1.3) {
            newEfactor = 1.3; // Minimum threshold in SM-2
        }

        final nextDate = DateTime.now().add(Duration(days: newInterval));

        return item.copyWith(
            srsInterval: newInterval,
            srsRepetition: newRepetition,
            srsEfactor: newEfactor,
            nextReviewDate: nextDate,
        );
    }
}
