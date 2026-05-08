import 'package:flutter/material.dart';

class AppTextStyles {
  static const String primaryFont = 'Nunito';
  static const String secondaryFont = 'Inter';

  static const TextStyle xs = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle sm = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle base = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle lg = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle xl = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle title = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle celebration = TextStyle(
    fontFamily: primaryFont,
    fontSize: 36,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle gameTitle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w900,
  );
}
