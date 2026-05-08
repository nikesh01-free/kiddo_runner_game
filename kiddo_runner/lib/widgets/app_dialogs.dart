import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_text_styles.dart';

enum AppToastVariant { warning, success, error, info }

void showAppToast({
  required BuildContext context,
  required String message,
  AppToastVariant variant = AppToastVariant.info,
}) {
  Color bg;
  IconData icon;

  switch (variant) {
    case AppToastVariant.warning:
      bg = AppColors.warning;
      icon = Icons.warning_rounded;
      break;
    case AppToastVariant.success:
      bg = AppColors.success;
      icon = Icons.check_circle_rounded;
      break;
    case AppToastVariant.error:
      bg = AppColors.error;
      icon = Icons.error_rounded;
      break;
    case AppToastVariant.info:
      bg = AppColors.info;
      icon = Icons.info_rounded;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.shadow3,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.base.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showAppModal({
  required BuildContext context,
  required String title,
  required Widget child,
  List<Widget>? actions,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.x2l),
        ),
        title: Text(
          title,
          style: AppTextStyles.xl.copyWith(color: AppColors.neutral900),
          textAlign: TextAlign.center,
        ),
        content: child,
        actions: actions,
      );
    },
  );
}
