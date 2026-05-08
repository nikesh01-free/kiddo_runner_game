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
import '../core/storage/music_manager.dart';
import '../services/reward_service.dart';
import '../widgets/reward_claim_dialog.dart';
import '../widgets/dancing_character.dart';

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
        decoration: BoxDecoration(
          gradient: stars > 0
              ? const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
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
                const SizedBox(height: AppSpacing.s4),
                Text(
                  stars > 0 ? 'Awesome Run! 🎉' : 'Good Try! 🌟',
                  style: AppTextStyles.celebration.copyWith(
                    color: stars > 0 ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Level $levelNumber Completed! 🏆',
                  style: AppTextStyles.base.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s3),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final fill = index < stars;
                    return Icon(
                      Icons.star_rounded,
                      size: 60,
                      color: fill
                          ? AppColors.secondary500
                          : AppColors.neutral300,
                    );
                  }),
                ),

                if (stars > 0) ...[
                  const SizedBox(height: AppSpacing.s3),
                  const DancingCharacter(size: 110),
                  const SizedBox(height: AppSpacing.s3),
                ],
                const SizedBox(height: AppSpacing.s3),

                AppCard(
                  variant: stars > 0
                      ? AppCardVariant.success
                      : AppCardVariant.warning,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
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
                      const Divider(height: 12),
                      _buildStatRow(
                        'Coins Earned',
                        '+$coins 🪙',
                        Icons.monetization_on_rounded,
                        AppColors.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),

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
                    MusicManager.playSfx('button_tap.wav');
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

                // Reward Claim Feature
                if (stars == 3) ...[
                  const SizedBox(height: AppSpacing.s4),
                  _buildClaimRewardButton(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClaimRewardButton(BuildContext context) {
    final nextReward = RewardService.getNextAvailableReward();
    if (nextReward == null) return const SizedBox.shrink();

    return AppButton(
      label: '🎁 CLAIM REWARD!',
      variant: AppButtonVariant.reward,
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => RewardClaimDialog(
            reward: nextReward,
            onClaimed: () async {
              await RewardService.claimReward(nextReward.id);
            },
          ),
        );
      },
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
