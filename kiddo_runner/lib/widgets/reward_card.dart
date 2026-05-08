import 'package:flutter/material.dart';
import '../models/reward_item.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class RewardCard extends StatelessWidget {
  final RewardItem reward;
  final bool isSelected;
  final VoidCallback? onTap;

  const RewardCard({
    super.key,
    required this.reward,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  reward.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.card_giftcard_rounded,
                      color: AppColors.primary300,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.primaryFont,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward.description,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.primaryFont,
                      fontSize: 12,
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            if (reward.isUnlocked)
              const Icon(Icons.check_circle_rounded, color: AppColors.success)
            else
              const Icon(Icons.lock_rounded, color: AppColors.neutral300),
          ],
        ),
      ),
    );
  }
}
