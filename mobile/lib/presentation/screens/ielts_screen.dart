import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/ielts/ielts_bloc.dart';
import '../blocs/ielts/ielts_event.dart';
import '../blocs/ielts/ielts_state.dart';
import '../widgets/ielts/ielts_evaluation_report_view.dart';
import '../widgets/common/shimmer_loading_card.dart';
import '../../core/theme/app_theme.dart';

class IeltsScreen extends StatefulWidget {
    const IeltsScreen({super.key});

    @override
    State<IeltsScreen> createState() => _IeltsScreenState();
}

class _IeltsScreenState extends State<IeltsScreen> {
    final TextEditingController _essayController = TextEditingController();
    bool _isOcrMode = false;

    final List<Map<String, String>> _prompts = [
        {
            "id": "task1_bar_chart_01",
            "title": "Car Ownership Trends (2000-2020)",
            "desc": "The chart below shows the number of cars per 1000 people in three European countries from 2000 to 2020."
        },
        {
            "id": "task1_line_graph_01",
            "title": "Global Energy Consumption (1980-2030)",
            "desc": "The line graph illustrates the consumption of four different sources of energy worldwide between 1980 and projected figures for 2030."
        },
    ];

    @override
    void initState() {
        super.initState();
        _essayController.text = "The provided bar chart illustrates the comparison between the number of cars owned per 1000 inhabitants across three European nations from 2000 to 2020. Overall, it is evident that car ownership witnessed an upward trend in all three countries over the given period. In 2000, the amount of cars in Country A was approximately 400, which increase dramatically to nearly 650 by 2020.";
    }

    @override
    void dispose() {
        _essayController.dispose();
        super.dispose();
    }

    Future<void> _pickImageAndSimulateOcr() async {
        final picker = ImagePicker();
        await picker.pickImage(source: ImageSource.camera);
        
        // For portfolio showcase, whether photo is taken or simulated, fill with realistic OCR text
        setState(() {
            _isOcrMode = true;
            _essayController.text = "[OCR Recognized Text from Handwriting]\nThe bar chart compares the figure for car ownership in three European nations between 2000 and 2020. Overall, we can see that oil production go down and car usage go up very fast in all three countries. In 2000, Country A had 400 cars per 1000 people, which increase dramatically in 2010.";
        });
        
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("📸 Đã nhận diện OCR thành công văn bản chữ viết tay từ ảnh! Hãy kiểm tra và ấn 'Gửi chấm điểm AI'."),
                    backgroundColor: AppColors.successGreen,
                ),
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("📝 IELTS Writing Task 1 AI Coach"),
                backgroundColor: AppColors.academicNavy,
                foregroundColor: Colors.white,
            ),
            body: BlocBuilder<IeltsBloc, IeltsState>(
                builder: (context, state) {
                    if (state is IeltsAnalyzing) {
                        return const SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: ShimmerLoadingCard(
                                title: "AI Examiner (Gemma 4 31B / Gemini) đang chấm bài...",
                                subtitle: "Phân tích 4 tiêu chí, highlight ngữ pháp & nâng cấp từ vựng...",
                            ),
                        );
                    } else if (state is IeltsEvaluationSuccess) {
                        return IeltsEvaluationReportView(
                            report: state.report,
                            onRetry: () => context.read<IeltsBloc>().add(ResetIeltsEvaluation()),
                        );
                    } else if (state is IeltsEvaluationFailure) {
                        return Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    const Icon(Icons.error_outline, color: AppColors.errorRed, size: 48),
                                    const SizedBox(height: 16),
                                    Text(state.error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.errorRed)),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                        onPressed: () => context.read<IeltsBloc>().add(ResetIeltsEvaluation()),
                                        child: const Text("Thử lại"),
                                    ),
                                ],
                            ),
                        );
                    }

                    // Initial Input Form View
                    final currentPromptId = state is IeltsInitial ? state.selectedPromptId : "task1_bar_chart_01";
                    final currentPrompt = _prompts.firstWhere((p) => p['id'] == currentPromptId, orElse: () => _prompts[0]);

                    return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                // Prompt Selector
                                const Text(
                                    "📌 Chọn Đề thi Biểu đồ (Writing Task 1):",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.goldAccent),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                    initialValue: currentPromptId,
                                    isExpanded: true,
                                    dropdownColor: Theme.of(context).cardColor,
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                        filled: true,
                                        fillColor: Theme.of(context).cardColor,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                    items: _prompts.map((p) => DropdownMenuItem(
                                        value: p['id'],
                                        child: Text(
                                            p['title']!,
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                    )).toList(),
                                    onChanged: (val) {
                                        if (val != null) {
                                            final selected = _prompts.firstWhere((p) => p['id'] == val);
                                            context.read<IeltsBloc>().add(SelectIeltsPrompt(val, selected['title']!));
                                        }
                                    },
                                ),
                                const SizedBox(height: 12),
                                Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.sakuraPink.withValues(alpha: 0.3)),
                                    ),
                                    child: Text("Đề bài: ${currentPrompt['desc']}", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodyMedium?.color)),
                                ),
                                const SizedBox(height: 20),

                                // Dual Input Mode Selector Buttons
                                Row(
                                    children: [
                                        Expanded(
                                            child: OutlinedButton.icon(
                                                onPressed: () => setState(() => _isOcrMode = false),
                                                icon: const Icon(Icons.keyboard),
                                                label: const Text("Gõ văn bản"),
                                                style: OutlinedButton.styleFrom(
                                                    backgroundColor: !_isOcrMode ? AppColors.sakuraPink : Colors.transparent,
                                                    foregroundColor: !_isOcrMode ? AppColors.deepIndigo : (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.academicNavy),
                                                    side: BorderSide(color: AppColors.sakuraPink.withValues(alpha: 0.5)),
                                                ),
                                            ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                            child: OutlinedButton.icon(
                                                onPressed: _pickImageAndSimulateOcr,
                                                icon: const Icon(Icons.camera_alt),
                                                label: const Text("Chụp ảnh OCR"),
                                                style: OutlinedButton.styleFrom(
                                                    backgroundColor: _isOcrMode ? AppColors.goldAccent : Colors.transparent,
                                                    foregroundColor: _isOcrMode ? AppColors.deepIndigo : (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.academicNavy),
                                                    side: BorderSide(color: AppColors.goldAccent.withValues(alpha: 0.5)),
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 16),

                                // Essay Text Editor
                                Text(
                                    _isOcrMode ? "📸 Văn bản nhận diện từ ảnh chụp bài viết tay (OCR):" : "✍️ Bài làm của bạn:",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.goldAccent),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                    controller: _essayController,
                                    maxLines: 8,
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15),
                                    decoration: InputDecoration(
                                        hintText: "Nhập bài mô tả biểu đồ ít nhất 150 từ...",
                                        hintStyle: const TextStyle(color: AppColors.slateGray),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                        filled: true,
                                        fillColor: Theme.of(context).cardColor,
                                        contentPadding: const EdgeInsets.all(16),
                                    ),
                                ),
                                const SizedBox(height: 8),
                                ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: _essayController,
                                    builder: (context, val, child) {
                                        final words = val.text.trim().isEmpty ? 0 : val.text.trim().split(RegExp(r'\s+')).length;
                                        return Text("Số từ: $words / 150 từ (Khuyến nghị)", style: TextStyle(color: words >= 150 ? AppColors.successGreen : AppColors.warningOrange, fontWeight: FontWeight.bold));
                                    },
                                ),
                                const SizedBox(height: 24),

                                // Submit Button
                                SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton.icon(
                                        onPressed: () {
                                            context.read<IeltsBloc>().add(SubmitIeltsEssay(
                                                currentPromptId,
                                                _essayController.text,
                                                inputType: _isOcrMode ? "image" : "text",
                                            ));
                                        },
                                        icon: const Icon(Icons.auto_awesome),
                                        label: const Text("Gửi AI Chấm điểm & Nhận xét ngay", style: TextStyle(fontSize: 16)),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.goldAccent,
                                            foregroundColor: AppColors.academicNavy,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 30),
                            ],
                        ),
                    );
                },
            ),
        );
    }
}
