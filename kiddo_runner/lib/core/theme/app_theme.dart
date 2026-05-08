import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: AppColors.primary500,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        secondary: AppColors.secondary500,
        surface: Colors.white,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.neutral900),
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyles.primaryFont,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.neutral900,
        ),
      ),
    );
  }
}
