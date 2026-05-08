import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../game/kiddo_game.dart';

class LevelIntroScreen extends StatelessWidget {
  const LevelIntroScreen({
    super.key,
    required this.levelNumber,
    required this.mode,
  });

  final int levelNumber;
  final String mode;

  @override
  Widget build(BuildContext context) {
    final isLvl1 = levelNumber == 1;
    final levelName = isLvl1
        ? (mode == 'math'
              ? 'Number Park — First Run'
              : 'Letter Park — First Run')
        : 'Level $levelNumber Dash';
    final topic = isLvl1
        ? (mode == 'math' ? 'Addition under 5' : 'Collect letters under 5')
        : (mode == 'math' ? 'Addition under 10' : 'Collect Letters');
    final timeLimit = isLvl1 ? '120 seconds' : '90 seconds';

    return Scaffold(
      appBar: AppBar(title: Text('Level $levelNumber Intro 🚀')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.s8),
                Text(
                  'Ready to Run? ⚡️',
                  style: AppTextStyles.celebration.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  "Let's solve the fun challenges on the track!",
                  style: AppTextStyles.base.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                AppCard(
                  variant: mode == 'math'
                      ? AppCardVariant.selected
                      : AppCardVariant.reward,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        mode == 'math'
                            ? Icons.calculate_rounded
                            : Icons.abc_rounded,
                        size: 64,
                        color: mode == 'math'
                            ? AppColors.primary500
                            : AppColors.accent500,
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        levelName,
                        style: AppTextStyles.xl.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic,
                        style: AppTextStyles.base.copyWith(
                          color: AppColors.neutral500,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: AppColors.neutral200, height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildIntroStat(
                            Icons.extension_rounded,
                            '10 Qs 🧩',
                            mode == 'math'
                                ? AppColors.primary500
                                : AppColors.accent500,
                          ),
                          _buildIntroStat(
                            Icons.favorite_rounded,
                            '5 Hearts ❤️',
                            AppColors.error,
                          ),
                          _buildIntroStat(
                            Icons.timer_rounded,
                            timeLimit,
                            AppColors.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                AppButton(
                  label: mode == 'math'
                      ? 'Start Math Run 🏃‍♂️'
                      : 'Start Word Run 🏃‍♀️',
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => GameWidget(
                          game: KiddoGame(
                            levelNumber: levelNumber,
                            mode: mode,
                            context: context,
                          ),
                        ),
                      ),
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

  Widget _buildIntroStat(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(
            fontFamily: AppTextStyles.primaryFont,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral700,
          ),
        ),
      ],
    );
  }
}
