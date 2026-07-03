import 'package:equatable/equatable.dart';
import '../../../../domain/entities/ielts_report.dart';

abstract class IeltsState extends Equatable {
    const IeltsState();
    @override
    List<Object?> get props => [];
}

class IeltsInitial extends IeltsState {
    final String selectedPromptId;
    final String selectedTitle;
    const IeltsInitial({this.selectedPromptId = "task1_bar_chart_01", this.selectedTitle = "Car Ownership Trends (2000-2020)"});
    @override
    List<Object?> get props => [selectedPromptId, selectedTitle];
}

class IeltsAnalyzing extends IeltsState {
    final String promptId;
    const IeltsAnalyzing(this.promptId);
    @override
    List<Object?> get props => [promptId];
}

class IeltsEvaluationSuccess extends IeltsState {
    final IeltsReport report;
    final String promptId;
    const IeltsEvaluationSuccess(this.report, this.promptId);
    @override
    List<Object?> get props => [report, promptId];
}

class IeltsEvaluationFailure extends IeltsState {
    final String error;
    const IeltsEvaluationFailure(this.error);
    @override
    List<Object?> get props => [error];
}
