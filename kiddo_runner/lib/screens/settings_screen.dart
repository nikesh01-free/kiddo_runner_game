// ignore_for_file: use_build_context_synchronously
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_input.dart';
import '../state/settings_provider.dart';
import '../state/profile_provider.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _gateController = TextEditingController();
  late int _num1;
  late int _num2;
  late int _answer;

  @override
  void initState() {
    super.initState();
    _generateGate();
  }

  void _generateGate() {
    final rand = Random();
    _num1 = rand.nextInt(8) + 2;
    _num2 = rand.nextInt(8) + 2;
    _answer = _num1 * _num2;
  }

  @override
  void dispose() {
    _gateController.dispose();
    super.dispose();
  }

  void _promptResetGate() {
    _generateGate();
    _gateController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Parent Gate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please solve this multiplication to confirm you are a parent:',
              ),
              const SizedBox(height: 16),
              Text(
                '$_num1 x $_num2 = ?',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primary500,
                ),
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: _gateController,
                label: 'Your Answer',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.outline,
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppButton(
              label: 'Confirm Reset',
              variant: AppButtonVariant.danger,
              onPressed: () async {
                final input = int.tryParse(_gateController.text.trim());
                if (input == _answer) {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  final profileProv = Provider.of<ProfileProvider>(
                    context,
                    listen: false,
                  );
                  await profileProv.resetAllProgress();

                  if (!mounted) return;
                  showAppToast(
                    context: context,
                    message: 'Progress reset successfully!',
                    variant: AppToastVariant.success,
                  );
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                } else {
                  if (mounted) {
                    showAppToast(
                      context: context,
                      message: 'Incorrect answer. Gate locked!',
                      variant: AppToastVariant.error,
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProv = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings ⚙️')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.s6),
            children: [
              Text(
                'Audio Settings 🎵',
                style: AppTextStyles.lg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Sound Effects',
                        style: AppTextStyles.base.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text('Fun chimes and jump sounds 🔊'),
                      value: settingsProv.soundEnabled,
                      activeThumbColor: AppColors.primary500,
                      onChanged: (val) => settingsProv.setSoundEnabled(val),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text(
                        'Background Music',
                        style: AppTextStyles.base.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text('Continuous running music 🎶'),
                      value: settingsProv.musicEnabled,
                      activeThumbColor: AppColors.primary500,
                      onChanged: (val) => settingsProv.setMusicEnabled(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Parent Controls 🔒',
                style: AppTextStyles.lg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Daily Playtime Limit ⏱️',
                      style: AppTextStyles.base.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: settingsProv.dailyPlayLimitMinutes,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 10,
                          child: Text('10 Minutes 🐣'),
                        ),
                        DropdownMenuItem(
                          value: 15,
                          child: Text('15 Minutes 🎒'),
                        ),
                        DropdownMenuItem(
                          value: 20,
                          child: Text('20 Minutes 🏆'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          settingsProv.setDailyPlayLimitMinutes(val);
                        }
                      },
                    ),
                    const Divider(height: 32),
                    AppButton(
                      label: 'RESET GAME PROGRESS 🔥',
                      variant: AppButtonVariant.danger,
                      onPressed: _promptResetGate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
