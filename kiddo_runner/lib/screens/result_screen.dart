import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../state/profile_provider.dart';
import 'home_screen.dart';
import 'mistake_review_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.levelNumber,
    required this.mode,
    required this.score,
    required this.stars,
    required this.accuracy,
    required this.coins,
    required this.mistakes,
  });

  final int levelNumber;
  final String mode;
  final int score;
  final int stars;
  final double accuracy;
  final int coins;
  final List<Map<String, String>> mistakes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stars > 0 ? 'Your Score! 🎉' : 'Keep Going! 🌟'),
        automaticallyImplyLeading: false,
      ),
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
                const SizedBox(height: AppSpacing.s8),
                Text(
                  stars > 0 ? 'Awesome Run! 🎉' : 'Good Try! 🌟',
                  style: AppTextStyles.celebration.copyWith(
                    color: stars > 0 ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  stars > 0
                      ? 'Super work! You completed the run beautifully!'
                      : 'You did so well! Let\'s learn and run again.',
                  style: AppTextStyles.base.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final fill = index < stars;
                    return Icon(
                      Icons.star_rounded,
                      size: 72,
                      color: fill
                          ? AppColors.secondary500
                          : AppColors.neutral300,
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.s6),

                AppCard(
                  variant: stars > 0
                      ? AppCardVariant.success
                      : AppCardVariant.warning,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildStatRow(
                        'Score',
                        '$score',
                        Icons.emoji_events_rounded,
                        AppColors.secondary500,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        'Accuracy',
                        '${accuracy.round()}%',
                        Icons.analytics_rounded,
                        AppColors.primary500,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        'Coins Earned',
                        '+$coins 🪙',
                        Icons.monetization_on_rounded,
                        AppColors.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),

                if (mistakes.isNotEmpty) ...[
                  AppButton(
                    label: 'Let’s Learn Again 🧠',
                    variant: AppButtonVariant.outline,
                    icon: Icons.assignment_late_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              MistakeReviewScreen(mistakes: mistakes),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s4),
                ],

                AppButton(
                  label: 'CONTINUE ➔',
                  onPressed: () {
                    final profileProv = Provider.of<ProfileProvider>(
                      context,
                      listen: false,
                    );
                    profileProv.completeLevel(
                      levelNumber: levelNumber,
                      score: score,
                      stars: stars,
                      accuracy: accuracy,
                      coins: coins,
                      mode: mode,
                      mistakes: mistakes,
                    );

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.base.copyWith(
                color: AppColors.neutral700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.lg.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
