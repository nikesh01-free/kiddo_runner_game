import '../models/reward_item.dart';
import '../core/storage/storage_manager.dart';
import 'package:flutter/foundation.dart';

class RewardService {
  static final List<RewardItem> _rewards = [

    RewardItem(
      id: 'cap_star',
      name: 'Super Star Cap',
      type: RewardType.cap,
      imagePath: 'assets/images/reward/star_cap.png',
      description: 'A cap for a true star!',
    ),
    RewardItem(
      id: 'shoes_rocket',
      name: 'Rocket Shoes',
      type: RewardType.shoes,
      imagePath: 'assets/images/reward/rocket_shoes.png',
      description: 'Zoom through the levels!',
    ),
    RewardItem(
      id: 'badge_math',
      name: 'Math Champion Badge',
      type: RewardType.badge,
      imagePath: 'assets/images/reward/math_badge.png',
      description: 'You are a math genius!',
    ),
    RewardItem(
      id: 'badge_word',
      name: 'Word Wizard Badge',
      type: RewardType.badge,
      imagePath: 'assets/images/reward/word_badge.png',
      description: 'Spelling master!',
    ),

    RewardItem(
      id: 'star_pack_gold',
      name: 'Golden Star Pack',
      type: RewardType.stars,
      imagePath: 'assets/images/reward/star_pack.png',
      description: 'A bundle of golden stars!',
    ),
  ];

  static List<RewardItem> get allRewards {
    final unlocked = StorageManager.unlockedRewards;
    return _rewards.map((r) {
      return r.copyWith(isUnlocked: unlocked.contains(r.id));
    }).toList();
  }

  static RewardItem? getNextAvailableReward() {
    final unlocked = StorageManager.unlockedRewards;
    for (final r in _rewards) {
      if (!unlocked.contains(r.id)) {
        return r;
      }
    }
    return null;
  }

  static Future<void> claimReward(String id) async {
    await StorageManager.unlockReward(id);
  }
}
