import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/ielts_repository_impl.dart';
import 'ielts_event.dart';
import 'ielts_state.dart';

class IeltsBloc extends Bloc<IeltsEvent, IeltsState> {
    final IeltsRepositoryImpl _repository;

    IeltsBloc(this._repository) : super(const IeltsInitial()) {
        on<SelectIeltsPrompt>(_onSelectPrompt);
        on<SubmitIeltsEssay>(_onSubmitEssay);
        on<ResetIeltsEvaluation>(_onReset);
    }

    void _onSelectPrompt(SelectIeltsPrompt event, Emitter<IeltsState> emit) {
        emit(IeltsInitial(selectedPromptId: event.promptId, selectedTitle: event.title));
    }

    Future<void> _onSubmitEssay(SubmitIeltsEssay event, Emitter<IeltsState> emit) async {
        emit(IeltsAnalyzing(event.promptId));
        try {
            final report = await _repository.evaluateEssay(
                event.promptId, 
                event.essayText,
                inputType: event.inputType,
            );
            emit(IeltsEvaluationSuccess(report, event.promptId));
        } catch (e) {
            String errorMsg = "⚠️ AI gặp gián đoạn trong quá trình chấm bài. Vui lòng thử lại!";
            final errStr = e.toString().toLowerCase();
            if (errStr.contains("timeout") || errStr.contains("timed out")) {
                errorMsg = "⏳ Hệ thống AI đang xử lý bài viết hoặc phản hồi chậm hơn 120s. Vui lòng kiểm tra lại server và thử lại!";
            } else if (errStr.contains("connection") || errStr.contains("socket") || errStr.contains("network") || errStr.contains("refused")) {
                errorMsg = "🌐 Không thể kết nối đến máy chủ AI (127.0.0.1:1112). Vui lòng kiểm tra lại kết nối mạng hoặc khởi động AI server!";
            } else {
                errorMsg = "⚠️ AI gặp lỗi trong quá trình chấm điểm (${e.toString().split(':').first}). Vui lòng thử lại!";
            }
            emit(IeltsEvaluationFailure(errorMsg));
        }
    }

    void _onReset(ResetIeltsEvaluation event, Emitter<IeltsState> emit) {
        if (state is IeltsEvaluationSuccess) {
            final current = state as IeltsEvaluationSuccess;
            emit(IeltsInitial(selectedPromptId: current.promptId));
        } else {
            emit(const IeltsInitial());
        }
    }
}
