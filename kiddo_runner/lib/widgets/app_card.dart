import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';

enum AppCardVariant { defaultCard, selected, game, success, warning, reward }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.defaultCard,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Border border;

    switch (variant) {
      case AppCardVariant.defaultCard:
        bg = Colors.white;
        border = Border.all(color: AppColors.neutral200);
        break;
      case AppCardVariant.selected:
        bg = AppColors.primary50;
        border = Border.all(color: AppColors.primary500, width: 2);
        break;
      case AppCardVariant.game:
        bg = AppColors.primary50;
        border = Border.all(color: AppColors.primary100, width: 1.5);
        break;
      case AppCardVariant.success:
        bg = AppColors.successLight;
        border = Border.all(color: AppColors.success, width: 1.5);
        break;
      case AppCardVariant.warning:
        bg = AppColors.warningLight;
        border = Border.all(color: AppColors.warning, width: 1.5);
        break;
      case AppCardVariant.reward:
        bg = AppColors.accent50;
        border = Border.all(color: AppColors.accent100, width: 1.5);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.x2l),
          border: border,
          boxShadow: AppShadows.shadow1,
        ),
        child: child,
      ),
    );
  }
}
