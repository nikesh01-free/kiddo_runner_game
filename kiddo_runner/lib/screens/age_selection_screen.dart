import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import 'character_selection_screen.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  String _selectedAge = '4-5';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'How Old Are You? 🎂',
                  style: AppTextStyles.celebration.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  'We’ll make your levels just right for you!',
                  style: AppTextStyles.base.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // 4-5 Category
                AppCard(
                  variant: _selectedAge == '4-5'
                      ? AppCardVariant.selected
                      : AppCardVariant.defaultCard,
                  onTap: () {
                    setState(() {
                      _selectedAge = '4-5';
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedAge == '4-5'
                              ? AppColors.primary100
                              : AppColors.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🐣', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ages 4–5',
                              style: AppTextStyles.lg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral900,
                              ),
                            ),
                            Text(
                              'Tiny Learner • Counting & Sounds',
                              style: AppTextStyles.sm.copyWith(
                                color: AppColors.neutral500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedAge == '4-5')
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary500,
                          size: 28,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),

                // 6-7 Category
                AppCard(
                  variant: _selectedAge == '6-7'
                      ? AppCardVariant.selected
                      : AppCardVariant.defaultCard,
                  onTap: () {
                    setState(() {
                      _selectedAge = '6-7';
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedAge == '6-7'
                              ? AppColors.secondary100
                              : AppColors.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🎒', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ages 6–7',
                              style: AppTextStyles.lg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral900,
                              ),
                            ),
                            Text(
                              'Smart Explorer • Addition & Spelling',
                              style: AppTextStyles.sm.copyWith(
                                color: AppColors.neutral500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedAge == '6-7')
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary500,
                          size: 28,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),

                // 8-10 Category
                AppCard(
                  variant: _selectedAge == '8-10'
                      ? AppCardVariant.selected
                      : AppCardVariant.defaultCard,
                  onTap: () {
                    setState(() {
                      _selectedAge = '8-10';
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedAge == '8-10'
                              ? AppColors.accent100
                              : AppColors.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🏆', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ages 8–10',
                              style: AppTextStyles.lg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral900,
                              ),
                            ),
                            Text(
                              'Brain Champion • Math & Big Words',
                              style: AppTextStyles.sm.copyWith(
                                color: AppColors.neutral500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedAge == '8-10')
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary500,
                          size: 28,
                        ),
                    ],
                  ),
                ),
                const Spacer(),

                AppButton(
                  label: 'NEXT ➡️',
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            CharacterSelectionScreen(ageGroup: _selectedAge),
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
