import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../state/settings_provider.dart';
import '../widgets/parent_challenge_dialog.dart';

class BreakScreen extends StatelessWidget {
  const BreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.warningLight, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Time for a Break! ☀️',
                  style: AppTextStyles.celebration.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Want more play time? Ask a parent to answer a quick question.',
                  style: AppTextStyles.base.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Consumer<SettingsProvider>(
                  builder: (context, settingsProv, child) {
                    final usedMinutes = (settingsProv.dailyPlayTimeSeconds / 60)
                        .floor();
                    final baseLimit = settingsProv.dailyPlayLimitMinutes;
                    final effectiveLimit =
                        settingsProv.effectiveDailyPlayLimitMinutes;
                    final extraMinutes = effectiveLimit - baseLimit;

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.neutral200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Today’s play time: $usedMinutes / $effectiveLimit minutes',
                              style: const TextStyle(
                                fontFamily: AppTextStyles.primaryFont,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Divider(height: 24),
                            _buildMetricRow('Base Limit:', '$baseLimit min'),
                            _buildMetricRow(
                              'Extra Time Today:',
                              '+$extraMinutes min',
                            ),
                            _buildMetricRow(
                              'Total Allowed Today:',
                              '$effectiveLimit min',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Consumer<SettingsProvider>(
                  builder: (context, settingsProv, child) {
                    final usedToday = settingsProv.isExtraPlayUsedToday;
                    return AppButton(
                      label: 'Extend Time 🔑',
                      onPressed: () async {
                        if (usedToday) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Extra time was already used today. Come back tomorrow.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final extended = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const ParentChallengeDialog(),
                        );

                        if (extended == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '30 more minutes unlocked for today! 🎉',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTextStyles.primaryFont,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTextStyles.primaryFont,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
