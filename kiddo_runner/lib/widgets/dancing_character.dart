import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/profile_provider.dart';

class DancingCharacter extends StatefulWidget {
  const DancingCharacter({super.key, this.size = 150});

  final double size;

  @override
  State<DancingCharacter> createState() => _DancingCharacterState();
}

class _DancingCharacterState extends State<DancingCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotationAnimation;

  int _currentFrame = 0;
  Timer? _frameTimer;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _frameTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          _currentFrame = (_currentFrame + 1) % 2;
        });
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _frameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context).activeProfile;
    if (profile == null) return const SizedBox.shrink();

    final characterId = profile.selectedCharacterId;
    String baseFolder = 'Male adventurer';
    String filePrefix = 'character_maleAdventurer';

    if (characterId == 'girl') {
      baseFolder = 'Female adventurer';
      filePrefix = 'character_femaleAdventurer';
    } else if (characterId == 'ninja_outfit') {
      baseFolder = 'Male person';
      filePrefix = 'character_malePerson';
    } else if (characterId == 'super_star') {
      baseFolder = 'Robot';
      filePrefix = 'character_robot';
    } else if (characterId == 'zombie') {
      baseFolder = 'Zombie';
      filePrefix = 'character_zombie';
    } else if (characterId == 'female_person') {
      baseFolder = 'Female person';
      filePrefix = 'character_femalePerson';
    }

    final basePath =
        'assets/images/characters/kenney_toon-characters/$baseFolder/PNG/Poses HD/';
    final imagePath = '${basePath}${filePrefix}_cheer$_currentFrame.png';

    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Image.asset(
              imagePath,
              height: widget.size,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to idle if cheer frames don't exist
                return Image.asset(
                  profile.characterImagePath,
                  height: widget.size,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
