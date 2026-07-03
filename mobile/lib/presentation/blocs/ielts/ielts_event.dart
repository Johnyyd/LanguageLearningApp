import 'package:equatable/equatable.dart';

abstract class IeltsEvent extends Equatable {
    const IeltsEvent();
    @override
    List<Object?> get props => [];
}

class SelectIeltsPrompt extends IeltsEvent {
    final String promptId;
    final String title;
    const SelectIeltsPrompt(this.promptId, this.title);
    @override
    List<Object?> get props => [promptId, title];
}

class SubmitIeltsEssay extends IeltsEvent {
    final String promptId;
    final String essayText;
    final String inputType; // "text" or "image"
    const SubmitIeltsEssay(this.promptId, this.essayText, {this.inputType = "text"});
    @override
    List<Object?> get props => [promptId, essayText, inputType];
}

class ResetIeltsEvaluation extends IeltsEvent {}
