import 'package:flutter/material.dart';

enum ThemeUnlockType { level, streak, coins, defaultUnlocked }

class ThemeReward {
  final String key;
  final String name;
  final String description;
  final ThemeUnlockType unlockType;
  final int unlockValue;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color laneColor;
  final String iconEmoji;

  const ThemeReward({
    required this.key,
    required this.name,
    required this.description,
    required this.unlockType,
    required this.unlockValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.laneColor,
    required this.iconEmoji,
  });
}
