// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_input.dart';
import '../widgets/app_dialogs.dart';
import '../state/profile_provider.dart';
import 'home_screen.dart';

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key, required this.ageGroup});

  final String ageGroup;

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedChar = 'boy';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accent50, Colors.white],
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
                  'Pick Your Runner! 🏃‍♂️',
                  style: AppTextStyles.celebration.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  'Every runner is equally powerful!',
                  style: AppTextStyles.base.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAvatarCard(
                      id: 'boy',
                      label: 'Leo ⚡️',
                      imagePath:
                          'assets/images/characters/kenney_toon-characters/Male adventurer/PNG/Poses HD/character_maleAdventurer_idle.png',
                      color: AppColors.primary500,
                    ),
                    _buildAvatarCard(
                      id: 'girl',
                      label: 'Mia ✨',
                      imagePath:
                          'assets/images/characters/kenney_toon-characters/Female adventurer/PNG/Poses HD/character_femaleAdventurer_idle.png',
                      color: AppColors.accent500,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),

                AppInput(
                  controller: _nameController,
                  label: 'Runner Name',
                  hint: 'e.g. SuperKid 🌟',
                ),
                const SizedBox(height: AppSpacing.s12),

                AppButton(
                  label: 'START ADVENTURE! 🚀',
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    final profileProv = Provider.of<ProfileProvider>(
                      context,
                      listen: false,
                    );
                    final navigator = Navigator.of(context);
                    final finalName = name.isEmpty ? 'Hero' : name;

                    await profileProv.createProfile(
                      ageGroup: widget.ageGroup,
                      characterId: _selectedChar,
                      childName: finalName,
                    );

                    if (!mounted) return;
                    showAppToast(
                      context: context,
                      message: 'Welcome aboard, $finalName! 🎉',
                      variant: AppToastVariant.success,
                    );
                    navigator.pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
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

  Widget _buildAvatarCard({
    required String id,
    required String label,
    required String imagePath,
    required Color color,
  }) {
    final isSelected = _selectedChar == id;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: AppCard(
          variant: isSelected
              ? AppCardVariant.selected
              : AppCardVariant.defaultCard,
          onTap: () {
            setState(() {
              _selectedChar = id;
            });
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withAlpha(51)
                      : AppColors.neutral100,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      id == 'boy' ? Icons.face_rounded : Icons.face_3_rounded,
                      size: 48,
                      color: color,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
              Text(
                label,
                style: AppTextStyles.lg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : AppColors.neutral700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
