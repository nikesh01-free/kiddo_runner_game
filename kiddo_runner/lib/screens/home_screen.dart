import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../state/profile_provider.dart';
import '../state/settings_provider.dart';
import 'level_map_screen.dart';
import 'parent_dashboard_screen.dart';
import 'settings_screen.dart';
import 'rewards_screen.dart';
import 'break_screen.dart';
import '../core/storage/storage_manager.dart';
import '../core/constants/theme_rewards.dart';
import '../models/theme_reward.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialMode = 'math'});

  final String initialMode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _activeMode;

  @override
  void initState() {
    super.initState();
    _activeMode = widget.initialMode;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPlayStreak();
      if (_isDailyClaimable()) {
        _showDailyRewardDialog();
      }
    });
  }

  void _checkPlayStreak() {
    try {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastActive = StorageManager.lastActiveDate;
      if (lastActive.isEmpty) {
        StorageManager.setPlayStreak(1);
        StorageManager.setLastActiveDate(todayStr);
      } else if (lastActive != todayStr) {
        final lastDate = DateTime.parse(lastActive);
        final todayDate = DateTime.parse(todayStr);
        final difference = todayDate.difference(lastDate).inDays;
        if (difference == 1) {
          final newStreak = StorageManager.playStreak + 1;
          StorageManager.setPlayStreak(newStreak);
          _checkStreakMilestones(newStreak);
        } else if (difference > 2) {
          StorageManager.setPlayStreak(1);
        }
        StorageManager.setLastActiveDate(todayStr);
      }
    } catch (_) {}
  }

  void _checkStreakMilestones(int streak) async {
    final listAch = StorageManager.unlockedAchievements;
    if (streak >= 7 && !listAch.contains('7_day_streak')) {
      await StorageManager.unlockAchievement('7_day_streak');
      final p = StorageManager.getChildProfile();
      if (p != null) {
        await StorageManager.saveChildProfile(
          p.copyWith(totalCoins: p.totalCoins + 150),
        );
      }
    }
  }

  bool _isDailyClaimable() {
    try {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      return StorageManager.lastDailyClaimDate != todayStr;
    } catch (_) {
      return false;
    }
  }

  void _showDailyRewardDialog() {
    final currentStreak = StorageManager.dailyStreakCount;
    final nextStreakDay = (currentStreak % 5) + 1;
    int rewardCoins = 20;
    if (nextStreakDay == 2) rewardCoins = 25;
    if (nextStreakDay == 3) rewardCoins = 30;
    if (nextStreakDay == 4) rewardCoins = 40;
    if (nextStreakDay >= 5) rewardCoins = 50;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool claimed = false;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🎁 Daily Reward! 🎁',
                      style: TextStyle(
                        fontFamily: AppTextStyles.primaryFont,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Day $nextStreakDay Streak Reward is ready!',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.primaryFont,
                        fontSize: 16,
                        color: AppColors.neutral700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 48)),
                        const SizedBox(width: 8),
                        Text(
                          '+$rewardCoins',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.primaryFont,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        if (claimed) return;
                        setDialogState(() {
                          claimed = true;
                        });
                        final todayStr = DateTime.now()
                            .toIso8601String()
                            .substring(0, 10);
                        await StorageManager.setLastDailyClaimDate(todayStr);
                        await StorageManager.setDailyStreakCount(nextStreakDay);

                        final p = StorageManager.getChildProfile();
                        if (p != null) {
                          await StorageManager.saveChildProfile(
                            p.copyWith(totalCoins: p.totalCoins + rewardCoins),
                          );
                          if (context.mounted) {
                            Provider.of<ProfileProvider>(
                              context,
                              listen: false,
                            ).loadProfile();
                          }
                        }

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Claimed $rewardCoins coins! 🪙 Streak is now Day $nextStreakDay! 🎉',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'CLAIM NOW! 🪙',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.primaryFont,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProv = Provider.of<SettingsProvider>(context);

    if (settingsProv.isDailyLimitReached) {
      return const BreakScreen();
    }

    return Scaffold(
      body: Consumer<ProfileProvider>(
        builder: (context, profileProv, child) {
          final profile = profileProv.activeProfile;
          if (profile == null) {
            return const Center(child: Text('No active profile.'));
          }

          final finalName = profile.childName.isEmpty
              ? 'Adventurer'
              : profile.childName;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary100,
                            radius: 28,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                profile.characterImagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.face_rounded,
                                    size: 32,
                                    color: AppColors.primary500,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s3),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, 👋',
                                style: AppTextStyles.sm.copyWith(
                                  color: AppColors.neutral500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                finalName,
                                style: AppTextStyles.title.copyWith(
                                  color: AppColors.neutral900,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildStatPill(
                            Icons.monetization_on_rounded,
                            '${profile.totalCoins}',
                            const Color(0xFFFFF3C7),
                            AppColors.secondary500,
                          ),
                          const SizedBox(width: 8),
                          _buildStatPill(
                            Icons.star_rounded,
                            '${profile.totalStars}',
                            const Color(0xFFE3F2FD),
                            AppColors.primary500,
                          ),
                          const SizedBox(width: 8),
                          _buildStatPill(
                            Icons.local_fire_department_rounded,
                            '${StorageManager.playStreak}',
                            const Color(0xFFFFEDD5),
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),

                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Row(
                      children: [
                        _buildModeTab(
                          'math',
                          'Math Mode',
                          Icons.calculate_rounded,
                          AppColors.primary500,
                        ),
                        _buildModeTab(
                          'spelling',
                          'Spelling',
                          Icons.abc_rounded,
                          AppColors.accent500,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),

                  AppCard(
                    variant: _activeMode == 'math'
                        ? AppCardVariant.selected
                        : AppCardVariant.reward,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          _activeMode == 'math'
                              ? Icons.calculate_rounded
                              : Icons.abc_rounded,
                          size: 72,
                          color: _activeMode == 'math'
                              ? AppColors.primary500
                              : AppColors.accent500,
                        ),
                        const Text(
                          '🌟 ⭐ 🌟',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          _activeMode == 'math'
                              ? 'MATH RUNNER 🌳'
                              : 'SPELLING RUNNER 🌲',
                          style: AppTextStyles.gameTitle.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activeMode == 'math'
                              ? 'Pass correct addition gates! ⚡️'
                              : 'Collect letters in alphabetical order! ✨',
                          style: AppTextStyles.base.copyWith(
                            color: AppColors.neutral700,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s6),
                        AppButton(
                          label: _activeMode == 'math'
                              ? 'Start Math Run 🏃‍♂️'
                              : 'Start Word Run 🏃‍♀️',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    LevelMapScreen(mode: _activeMode),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  
                  // Theme Preview Card
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RewardsScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ThemeRewards.getTheme(StorageManager.equippedTheme).primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: AppShadows.shadow1,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ThemeRewards.getTheme(StorageManager.equippedTheme).backgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              ThemeRewards.getTheme(StorageManager.equippedTheme).iconEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'World Theme',
                                  style: AppTextStyles.xs.copyWith(
                                    color: AppColors.neutral500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ThemeRewards.getTheme(StorageManager.equippedTheme).name,
                                  style: AppTextStyles.base.copyWith(
                                    color: AppColors.neutral900,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s6),

                  Row(
                    children: [
                      _buildMenuCard(
                        label: 'Learning Report',
                        icon: Icons.insights_rounded,
                        color: AppColors.success,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ParentDashboardScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: AppSpacing.s3),
                      _buildMenuCard(
                        label: 'Rewards',
                        icon: Icons.emoji_events_rounded,
                        color: AppColors.secondary500,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RewardsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  AppCard(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.settings_rounded,
                          color: AppColors.neutral600,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Settings',
                          style: AppTextStyles.base.copyWith(
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
          );
        },
      ),
    );
  }

  Widget _buildStatPill(
    IconData icon,
    String value,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTextStyles.primaryFont,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(String mode, String label, IconData icon, Color color) {
    final isSelected = _activeMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: isSelected ? AppShadows.shadow1 : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? color : AppColors.neutral500,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.base.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? AppColors.neutral900
                      : AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: AppCard(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.base.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
