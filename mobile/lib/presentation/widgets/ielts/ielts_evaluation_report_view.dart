import 'package:flutter/material.dart';
import '../../../../domain/entities/ielts_report.dart';
import '../../../../core/theme/app_theme.dart';

class IeltsEvaluationReportView extends StatelessWidget {
    final IeltsReport report;
    final VoidCallback onRetry;

    const IeltsEvaluationReportView({
        super.key,
        required this.report,
        required this.onRetry,
    });

    @override
    Widget build(BuildContext context) {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Overall Band Header
                    Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [AppColors.academicNavy, AppColors.slateGray],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                                BoxShadow(color: AppColors.academicNavy.withValues(alpha: 0.3), blurRadius: 12),
                            ],
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            const Text("IELTS WRITING TASK 1", style: TextStyle(color: AppColors.goldAccent, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 6),
                                            Text(
                                                "Band Score Dự đoán",
                                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
                                            ),
                                        ],
                                    ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        color: AppColors.goldAccent,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: AppColors.goldAccent.withValues(alpha: 0.4), blurRadius: 10)],
                                    ),
                                    child: Text(
                                        "${report.overallBand}",
                                        style: const TextStyle(color: AppColors.academicNavy, fontSize: 26, fontWeight: FontWeight.bold),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    const SizedBox(height: 20),

                    // 4 Criteria Breakdown Cards
                    const Text("Phân tích 4 Tiêu chí IELTS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                            _buildCriteriaCard(context, "Task Achievement", report.taskAchievement, Icons.track_changes),
                            _buildCriteriaCard(context, "Cohesion & Coherence", report.cohesionCoherence, Icons.account_tree),
                            _buildCriteriaCard(context, "Lexical Resource", report.lexicalResource, Icons.menu_book),
                            _buildCriteriaCard(context, "Grammar Accuracy", report.grammaticalAccuracy, Icons.spellcheck),
                        ],
                    ),
                    const SizedBox(height: 24),

                    // General AI Comment
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppColors.sakuraPink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.sakuraPink),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Row(
                                    children: [
                                        Icon(Icons.auto_awesome, color: AppColors.sakuraPink),
                                        SizedBox(width: 8),
                                        Expanded(child: Text("Nhận xét từ AI Examiner", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                    ],
                                ),
                                const SizedBox(height: 8),
                                Text(report.generalComment, style: const TextStyle(fontSize: 15, height: 1.4)),
                            ],
                        ),
                    ),
                    const SizedBox(height: 24),

                    // Grammar Corrections Section
                    if (report.grammarErrors.isNotEmpty) ...[
                        const Text("Lỗi Ngữ pháp & Câu sửa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.errorRed)),
                        const SizedBox(height: 12),
                        ...report.grammarErrors.map((err) => _buildErrorCard(context, err)),
                        const SizedBox(height: 24),
                    ],

                    // Lexical Upgrades Section
                    if (report.lexicalUpgrades.isNotEmpty) ...[
                        const Text("Đề xuất Nâng cấp Từ vựng (Academic Lexicon)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                        const SizedBox(height: 12),
                        ...report.lexicalUpgrades.map((lex) => _buildLexicalCard(context, lex)),
                        const SizedBox(height: 24),
                    ],

                    // Retry Button
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Viết lại hoặc Chọn đề khác"),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldAccent,
                                foregroundColor: AppColors.academicNavy,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                        ),
                    ),
                    const SizedBox(height: 30),
                ],
            ),
        );
    }

    Widget _buildCriteriaCard(BuildContext context, String title, double score, IconData icon) {
        return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slateGray.withValues(alpha: 0.2)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            Icon(icon, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.academicNavy),
                            Text("$score", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.academicNavy)),
                        ],
                    ),
                    const SizedBox(height: 6),
                    Text(title, style: const TextStyle(fontSize: 12, color: AppColors.slateGray, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
            ),
        );
    }

    Widget _buildErrorCard(BuildContext context, GrammarError err) {
        return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            children: [
                                const Icon(Icons.error_outline, color: AppColors.errorRed, size: 18),
                                const SizedBox(width: 6),
                                Expanded(child: Text("Dòng ${err.lineNumber}: Câu gốc sai", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorRed))),
                            ],
                        ),
                        const SizedBox(height: 4),
                        Text("\"${err.original}\"", style: const TextStyle(decoration: TextDecoration.lineThrough, color: AppColors.slateGray)),
                        const Divider(height: 20),
                        const Row(
                            children: [
                                Icon(Icons.check_circle_outline, color: AppColors.successGreen, size: 18),
                                SizedBox(width: 6),
                                Expanded(child: Text("Câu sửa chuẩn", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.successGreen))),
                            ],
                        ),
                        const SizedBox(height: 4),
                        Text("\"${err.corrected}\"", style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(8)),
                            child: Text("💡 Giải thích: ${err.explanation}", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodyMedium?.color)),
                        ),
                    ],
                ),
            ),
        );
    }

    Widget _buildLexicalCard(BuildContext context, LexicalUpgrade lex) {
        return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            children: [
                                const Icon(Icons.auto_graph, color: AppColors.goldAccent, size: 18),
                                const SizedBox(width: 6),
                                Expanded(child: Text("Từ thông thường: \"${lex.originalWord}\"", style: const TextStyle(fontWeight: FontWeight.bold))),
                            ],
                        ),
                        const SizedBox(height: 8),
                        Text("🚀 Từ vựng Học thuật nâng cao:", style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.slateGray)),
                        const SizedBox(height: 6),
                        Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: lex.suggestedAcademicWords.map((w) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: AppColors.academicNavy,
                                    borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                    w,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                ),
                            )).toList(),
                        ),
                        const SizedBox(height: 8),
                        Text("Ví dụ ngữ cảnh: \"${lex.contextExample}\"", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.slateGray)),
                    ],
                ),
            ),
        );
    }
}
