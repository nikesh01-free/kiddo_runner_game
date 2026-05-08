import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_card.dart';

class MistakeReviewScreen extends StatelessWidget {
  const MistakeReviewScreen({super.key, required this.mistakes});

  final List<Map<String, String>> mistakes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Let’s Learn Again 🧠')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: mistakes.isEmpty
              ? Center(
                  child: Text(
                    'No mistakes to review! Perfect job! 🌟',
                    style: AppTextStyles.lg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.s6),
                  itemCount: mistakes.length,
                  itemBuilder: (context, index) {
                    final m = mistakes[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s4),
                      child: AppCard(
                        variant: AppCardVariant.warning,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_rounded,
                                  color: AppColors.warningDark,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Challenge ${index + 1} 🧩',
                                  style: AppTextStyles.sm.copyWith(
                                    color: AppColors.neutral600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              m['question'] ?? 'Unknown Question',
                              style: AppTextStyles.lg.copyWith(
                                color: AppColors.neutral900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorLight,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your choice ❌',
                                          style: AppTextStyles.xs.copyWith(
                                            color: AppColors.errorDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          m['selected'] ?? '',
                                          style: AppTextStyles.base.copyWith(
                                            color: AppColors.errorDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.successLight,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Correct answer ✅',
                                          style: AppTextStyles.xs.copyWith(
                                            color: AppColors.successDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          m['correct'] ?? '',
                                          style: AppTextStyles.base.copyWith(
                                            color: AppColors.successDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
