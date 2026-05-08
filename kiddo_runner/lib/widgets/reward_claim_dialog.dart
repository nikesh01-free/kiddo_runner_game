import 'package:flutter/material.dart';
import '../models/reward_item.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/storage/music_manager.dart';
import '../core/storage/storage_manager.dart';
import '../state/profile_provider.dart';
import 'package:provider/provider.dart';

class RewardClaimDialog extends StatefulWidget {
  final RewardItem reward;
  final VoidCallback? onClaimed;

  const RewardClaimDialog({
    super.key,
    required this.reward,
    this.onClaimed,
  });

  @override
  State<RewardClaimDialog> createState() => _RewardClaimDialogState();
}

class _RewardClaimDialogState extends State<RewardClaimDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _animController.forward();
    _playRewardSound();
  }

  void _playRewardSound() {
    try {
      MusicManager.playSfx('level_complete.wav');
    } catch (e) {
      debugPrint('Could not play reward sound: $e');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary500.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Custom Confetti
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ConfettiPainter(_animController.value),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),

          // Content
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'CONGRATULATIONS! 🎉',
                    style: TextStyle(
                      fontFamily: AppTextStyles.primaryFont,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Reward Image
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary100, width: 4),
                    ),
                    child: Center(
                      child: Image.asset(
                        widget.reward.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            _getFallbackIcon(widget.reward.type),
                            size: 64,
                            color: AppColors.primary300,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    widget.reward.name,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.primaryFont,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMessage(widget.reward.type),
                    style: const TextStyle(
                      fontFamily: AppTextStyles.primaryFont,
                      fontSize: 14,
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  if (widget.reward.type == RewardType.outfit || 
                      widget.reward.type == RewardType.skin)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        if (widget.reward.type == RewardType.outfit || 
                            widget.reward.type == RewardType.skin) {
                          final profileProv = Provider.of<ProfileProvider>(
                            context,
                            listen: false,
                          );
                          await profileProv.updateCharacter(widget.reward.id);
                        }
                        Navigator.of(context).pop();
                        widget.onClaimed?.call();
                      },
                      child: const Text(
                        'USE NOW! ✨',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onClaimed?.call();
                    },
                    child: const Text(
                      'COLLECT & CONTINUE',
                      style: TextStyle(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFallbackIcon(RewardType type) {
    switch (type) {
      case RewardType.outfit: return Icons.checkroom_rounded;
      case RewardType.cap: return Icons.checkroom_rounded; 
      case RewardType.shoes: return Icons.directions_run_rounded;
      case RewardType.badge: return Icons.verified_rounded;
      case RewardType.skin: return Icons.face_rounded;
      case RewardType.stars: return Icons.stars_rounded;
    }
    return Icons.card_giftcard_rounded;
  }

  String _getMessage(RewardType type) {
    switch (type) {
      case RewardType.outfit: return "Yay! You unlocked a new outfit!";
      case RewardType.badge: return "Super job! New badge earned!";
      case RewardType.stars: return "Amazing! You earned a Star Pack!";
      default: return "Super job! New reward unlocked!";
    }
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.red, Colors.blue, Colors.yellow, Colors.green,
      Colors.pink, Colors.orange, Colors.purple, Colors.cyan,
    ];
    final rand = List.generate(30, (i) => i);
    for (final i in rand) {
      final paint = Paint()..color = colors[i % colors.length].withOpacity(1.0 - progress);
      final x = (size.width * ((i * 37 + 13) % 100) / 100);
      final y = size.height * progress * ((i * 53 + 7) % 100) / 100;
      canvas.drawCircle(Offset(x, y), 5, paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}
