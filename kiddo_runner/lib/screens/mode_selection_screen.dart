import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_dialogs.dart';
import 'level_map_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  String _selectedMode = 'math';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Adventure!')),
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
                const SizedBox(height: AppSpacing.s4),
                Text(
                  'Choose Your Adventure! 🗺️',
                  style: AppTextStyles.celebration.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  'Which fun game would you like to play today?',
                  style: AppTextStyles.base.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // Math Runner
                AppCard(
                  variant: _selectedMode == 'math'
                      ? AppCardVariant.selected
                      : AppCardVariant.defaultCard,
                  onTap: () {
                    setState(() {
                      _selectedMode = 'math';
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedMode == 'math'
                              ? AppColors.primary100
                              : AppColors.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calculate_rounded,
                          size: 36,
                          color: AppColors.primary500,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Math Runner 🌳',
                              style: AppTextStyles.lg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral900,
                              ),
                            ),
                            Text(
                              'Solve math gates & collect coins!',
                              style: AppTextStyles.sm.copyWith(
                                color: AppColors.neutral500,
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

                // Spelling Adventure
                AppCard(
                  variant: _selectedMode == 'spelling'
                      ? AppCardVariant.selected
                      : AppCardVariant.defaultCard,
                  onTap: () {
                    setState(() {
                      _selectedMode = 'spelling';
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedMode == 'spelling'
                              ? AppColors.accent100
                              : AppColors.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.abc_rounded,
                          size: 36,
                          color: AppColors.accent500,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spelling Adventure 🌲',
                              style: AppTextStyles.lg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral900,
                              ),
                            ),
                            Text(
                              'Collect letters & spell words!',
                              style: AppTextStyles.sm.copyWith(
                                color: AppColors.neutral500,
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

                // Mixed Mode (Locked)
                AppCard(
                  variant: AppCardVariant.defaultCard,
                  onTap: () {
                    showAppToast(
                      context: context,
                      message: 'Mixed Mode unlocks after Level 5. 🔒',
                      variant: AppToastVariant.warning,
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 36,
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Mixed Mode',
                                  style: AppTextStyles.lg.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 16,
                                  color: AppColors.neutral500,
                                ),
                              ],
                            ),
                            Text(
                              'Combine math & words! (Level 5)',
                              style: AppTextStyles.sm.copyWith(
                                color: AppColors.neutral500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                AppButton(
                  label: 'PLAY NOW! 🚀',
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => LevelMapScreen(mode: _selectedMode),
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
}
