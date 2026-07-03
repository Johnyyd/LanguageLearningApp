import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';

class ShimmerLoadingCard extends StatelessWidget {
    final String title;
    final String subtitle;

    const ShimmerLoadingCard({
        super.key,
        this.title = "AI Examiner đang chấm điểm...",
        this.subtitle = "Đang phân tích Task Achievement & Cohesion...",
    });

    @override
    Widget build(BuildContext context) {
        final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.academicNavy;
        final subtextColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.slateGray;
        final skeletonColor = Theme.of(context).dividerColor.withValues(alpha: 0.2);

        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                    BoxShadow(
                        color: AppColors.academicNavy.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                    ),
                ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        children: [
                            const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.goldAccent),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                                        const SizedBox(height: 4),
                                        Text(subtitle, style: TextStyle(fontSize: 12, color: subtextColor.withValues(alpha: 0.8))),
                                    ],
                                ),
                            ),
                        ],
                    ),
                    const SizedBox(height: 24),
                    Shimmer.fromColors(
                        baseColor: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                        highlightColor: Theme.of(context).cardColor,
                        period: const Duration(milliseconds: 1200),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                // Band Score Circle Skeleton
                                Center(
                                    child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                            color: skeletonColor,
                                            shape: BoxShape.circle,
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 24),
                                // Title Line
                                Container(
                                    width: 180,
                                    height: 16,
                                    decoration: BoxDecoration(
                                        color: skeletonColor,
                                        borderRadius: BorderRadius.circular(8),
                                    ),
                                ),
                                const SizedBox(height: 12),
                                // Paragraph Lines
                                ...List.generate(4, (index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                        width: double.infinity,
                                        height: 12,
                                        decoration: BoxDecoration(
                                            color: skeletonColor,
                                            borderRadius: BorderRadius.circular(6),
                                        ),
                                    ),
                                )),
                                const SizedBox(height: 16),
                                // Radar Chart Skeleton Box
                                Container(
                                    width: double.infinity,
                                    height: 140,
                                    decoration: BoxDecoration(
                                        color: skeletonColor,
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }
}
