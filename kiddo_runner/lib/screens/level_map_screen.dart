import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_dialogs.dart';
import '../state/profile_provider.dart';
import 'level_intro_screen.dart';
import '../core/storage/music_manager.dart';

class LevelMapScreen extends StatelessWidget {
  const LevelMapScreen({super.key, required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final worldTitle = mode == 'math' ? 'Number Park 🌳' : 'Alphabet Forest 🌲';
    final activeColor = mode == 'math'
        ? AppColors.primary500
        : AppColors.accent500;
    final pathColor = mode == 'math'
        ? AppColors.primary300
        : AppColors.accent300;

    return Scaffold(
      appBar: AppBar(title: Text(worldTitle)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<ProfileProvider>(
          builder: (context, profileProv, child) {
            final progressList = profileProv.levelProgressList
                .where((e) => e.mode == mode)
                .toList();

            if (progressList.isEmpty) {
              return const Center(
                child: Text(
                  'Initializing levels... 🚀',
                  style: TextStyle(
                    fontFamily: AppTextStyles.primaryFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              itemCount: progressList.length,
              itemBuilder: (context, index) {
                final levelProgress = progressList[index];
                final isUnlocked = levelProgress.isUnlocked;
                final isCompleted = levelProgress.isCompleted;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (isUnlocked) {
                          MusicManager.playSfx('button_tap.wav');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LevelIntroScreen(
                                levelNumber: levelProgress.levelNumber,
                                mode: mode,
                              ),
                            ),
                          );
                        } else {
                          showAppToast(
                            context: context,
                            message:
                                'Complete the previous level to unlock this one. 🔒',
                            variant: AppToastVariant.warning,
                          );
                        }
                      },
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? (isCompleted ? AppColors.success : activeColor)
                              : AppColors.neutral300,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isUnlocked
                                  ? (isCompleted
                                        ? const Color(0x3F22C55E)
                                        : activeColor.withValues(alpha: 0.4))
                                  : Colors.transparent,
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 6),
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (!isCompleted && isUnlocked)
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFB300).withOpacity(0.3),
                                    width: 4,
                                  ),
                                ),
                              ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Lv ${levelProgress.levelNumber}',
                                  style: AppTextStyles.base.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                if (isUnlocked && levelProgress.bestStars > 0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '✅',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      ...List.generate(
                                        levelProgress.bestStars,
                                        (_) => const Icon(
                                          Icons.star_rounded,
                                          size: 14,
                                          color: AppColors.secondary500,
                                        ),
                                      ),
                                    ],
                                  )
                                else if (!isUnlocked)
                                  const Icon(
                                    Icons.lock_rounded,
                                    size: 24,
                                    color: Colors.white,
                                  )
                                else
                                  const Text(
                                    'PLAY ⭐️',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index < progressList.length - 1)
                      Container(
                        width: 10,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              isUnlocked && progressList[index + 1].isUnlocked
                              ? pathColor
                              : AppColors.neutral300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
