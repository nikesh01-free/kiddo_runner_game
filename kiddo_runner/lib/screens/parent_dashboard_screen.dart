import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../state/profile_provider.dart';
import '../state/settings_provider.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProv = Provider.of<ProfileProvider>(context);
    final settingsProv = Provider.of<SettingsProvider>(context);

    final mathAccuracy = profileProv.getAverageMathAccuracy();
    final spellingAccuracy = profileProv.getAverageSpellingAccuracy();
    final weakTopic = profileProv.getWeakTopic();

    final minutesPlayed = (settingsProv.dailyPlayTimeSeconds / 60).floor();

    return Scaffold(
      appBar: AppBar(title: const Text('Learning Report 📊')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Weekly Overview 📈',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  'Monitor your child\'s learning progress and play session limits.',
                  style: AppTextStyles.base.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),

                AppCard(
                  variant: AppCardVariant.game,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_rounded,
                        size: 48,
                        color: AppColors.primary500,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Playtime ⏱️',
                              style: AppTextStyles.sm.copyWith(
                                color: AppColors.neutral600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$minutesPlayed / ${settingsProv.effectiveDailyPlayLimitMinutes} mins',
                              style: AppTextStyles.title.copyWith(
                                color: AppColors.neutral900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),

                Row(
                  children: [
                    _buildMetricCard(
                      title: 'Math Power 🔢',
                      value: '${mathAccuracy.round()}%',
                      icon: Icons.calculate_rounded,
                      color: AppColors.primary500,
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    _buildMetricCard(
                      title: 'Word Power 🔠',
                      value: '${spellingAccuracy.round()}%',
                      icon: Icons.abc_rounded,
                      color: AppColors.accent500,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s4),

                AppCard(
                  variant: AppCardVariant.warning,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.assignment_late_rounded,
                            color: AppColors.warningDark,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Focus Area (Weak Topics) 🧠',
                            style: AppTextStyles.base.copyWith(
                              color: AppColors.neutral700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        weakTopic,
                        style: AppTextStyles.lg.copyWith(
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Practice these together to boost their performance! ✨',
                        style: AppTextStyles.sm.copyWith(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.title.copyWith(
                color: AppColors.neutral900,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.sm.copyWith(
                color: AppColors.neutral500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
