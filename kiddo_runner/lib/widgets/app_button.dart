import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, danger, reward }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    Color bg;
    Color border;
    Color fg;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = isEnabled ? AppColors.primary500 : AppColors.neutral300;
        border = Colors.transparent;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = isEnabled ? AppColors.secondary500 : AppColors.neutral300;
        border = Colors.transparent;
        fg = AppColors.neutral900;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        border = isEnabled ? AppColors.primary500 : AppColors.neutral300;
        fg = isEnabled ? AppColors.primary500 : AppColors.neutral500;
        break;
      case AppButtonVariant.danger:
        bg = isEnabled ? AppColors.error : AppColors.neutral300;
        border = Colors.transparent;
        fg = Colors.white;
        break;
      case AppButtonVariant.reward:
        bg = isEnabled ? const Color(0xFFFF9800) : AppColors.neutral300;
        border = Colors.transparent;
        fg = Colors.white;
        break;
    }

    double height;
    TextStyle style;
    double iconSize;

    switch (widget.size) {
      case AppButtonSize.sm:
        height = 36;
        style = AppTextStyles.xs.copyWith(fontWeight: FontWeight.bold);
        iconSize = 16;
        break;
      case AppButtonSize.md:
        height = 48;
        style = AppTextStyles.sm.copyWith(fontWeight: FontWeight.bold);
        iconSize = 20;
        break;
      case AppButtonSize.lg:
        height = 56;
        style = AppTextStyles.base.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        );
        iconSize = 24;
        break;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _animController.forward() : null,
        onTapUp: isEnabled
            ? (_) {
                _animController.reverse();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: isEnabled ? () => _animController.reverse() : null,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: border, width: 2),
            boxShadow: widget.variant != AppButtonVariant.outline && isEnabled
                ? AppShadows.shadow1
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: fg, size: iconSize),
                const SizedBox(width: 8),
              ],
              Text(widget.label, style: style.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
