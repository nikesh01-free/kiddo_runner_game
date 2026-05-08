import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/reward_service.dart';
import '../models/reward_item.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../state/profile_provider.dart';
import '../core/storage/storage_manager.dart';
import '../models/child_profile.dart';
import '../core/constants/theme_rewards.dart';
import '../models/theme_reward.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _outfits = [
    {
      'key': 'default_runner',
      'name': 'Leo (Speedy Dash)',
      'cost': 0,
      'imagePath':
          'assets/images/characters/kenney_toon-characters/Male adventurer/PNG/Poses HD/character_maleAdventurer_idle.png',
    },
    {
      'key': 'girl',
      'name': 'Mia (Nature Scout)',
      'cost': 50,
      'imagePath':
          'assets/images/characters/kenney_toon-characters/Female adventurer/PNG/Poses HD/character_femaleAdventurer_idle.png',
    },
    {
      'key': 'ninja_outfit',
      'name': 'Shadow Ninja',
      'cost': 100,
      'imagePath':
          'assets/images/characters/kenney_toon-characters/Male person/PNG/Poses HD/character_malePerson_idle.png',
    },
    {
      'key': 'zombie',
      'name': 'Glow Zombie',
      'cost': 150,
      'imagePath':
          'assets/images/characters/kenney_toon-characters/Zombie/PNG/Poses HD/character_zombie_idle.png',
    },
    {
      'key': 'female_person',
      'name': 'Cosmic Ranger',
      'cost': 200,
      'imagePath':
          'assets/images/characters/kenney_toon-characters/Female person/PNG/Poses HD/character_femalePerson_idle.png',
    },
    {
      'key': 'super_star',
      'name': 'Metal Robot',
      'cost': 250,
      'imagePath':
          'assets/images/characters/kenney_toon-characters/Robot/PNG/Poses HD/character_robot_idle.png',
    },
  ];

  final List<Map<String, dynamic>> _hats = [
    {
      'key': 'none',
      'name': 'No Hat',
      'cost': 0,
      'image': 'assets/images/reward/no_hat.png'
    },
    {
      'key': 'propeller_hat',
      'name': 'Propeller Hat',
      'cost': 20,
      'image': 'assets/images/reward/hat_propeller.png'
    },
    {
      'key': 'cowboy_hat',
      'name': 'Cowboy Hat',
      'cost': 40,
      'image': 'assets/images/reward/hat_cowboy.png'
    },
    {
      'key': 'wizard_hat',
      'name': 'Wizard Hat',
      'cost': 60,
      'image': 'assets/images/reward/hat_wizard.png'
    },
  ];

  final List<Map<String, dynamic>> _trails = [
    {
      'key': 'none',
      'name': 'No Trail',
      'cost': 0,
      'image': 'assets/images/reward/no_trail.png'
    },
    {
      'key': 'rainbow_trail',
      'name': 'Rainbow Trail',
      'cost': 30,
      'image': 'assets/images/reward/trail_rainbow.png'
    },
    {
      'key': 'star_trail',
      'name': 'Star Trail',
      'cost': 50,
      'image': 'assets/images/reward/trail_star.png'
    },
    {
      'key': 'fire_trail',
      'name': 'Fire Trail',
      'cost': 70,
      'image': 'assets/images/reward/trail_fire.png'
    },
  ];

  final List<ThemeReward> _themes = ThemeRewards.themes;

  final List<Map<String, dynamic>> _achievements = [
    {
      'key': 'first_run',
      'name': '🏃‍♂️ First Run',
      'desc': 'Complete your very first game run!',
      'reward': 20,
    },
    {
      'key': 'perfect_level',
      'name': '⭐ Perfect Star',
      'desc': 'Finish any level with 3 stars!',
      'reward': 50,
    },
    {
      'key': 'no_mistakes',
      'name': '🎯 Super Solver',
      'desc': 'Complete a level with zero mistakes!',
      'reward': 75,
    },
    {
      'key': 'math_master',
      'name': '🧠 Math Master',
      'desc': 'Unlock and complete level 10 in Math Mode!',
      'reward': 100,
    },
    {
      'key': 'word_wizard',
      'name': '✍️ Word Wizard',
      'desc': 'Unlock and complete level 10 in Spelling Mode!',
      'reward': 100,
    },
    {
      'key': '100_coins',
      'name': '💰 Coin Collector',
      'desc': 'Amass 100 or more total coins!',
      'reward': 50,
    },
    {
      'key': '7_day_streak',
      'name': '🔥 Weekly Hero',
      'desc': 'Play for 7 consecutive days!',
      'reward': 150,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _integrateServiceRewards();
  }

  void _integrateServiceRewards() {
    final serviceRewards = RewardService.allRewards;

    for (final reward in serviceRewards) {
      final map = {
        'key': reward.id,
        'name': reward.name,
        'cost': 0, // Service rewards are earned, not bought
        'image': reward.imagePath,
        'imagePath': reward.imagePath,
        'isServiceReward': true,
        'description': reward.description,
      };

      switch (reward.type) {
        case RewardType.outfit:
        case RewardType.skin:
          if (!_outfits.any((o) => o['key'] == reward.id)) {
            _outfits.add(map);
          }
          break;
        case RewardType.cap:
          if (!_hats.any((h) => h['key'] == reward.id)) {
            _hats.add(map);
          }
          break;
        case RewardType.shoes:
          if (!_hats.any((h) => h['key'] == reward.id)) {
            _hats.add(map);
          }
          break;
        case RewardType.badge:
          if (!_achievements.any((a) => a['key'] == reward.id)) {
            _achievements.add({
              'key': reward.id,
              'name': reward.name,
              'desc': reward.description,
              'reward': 0,
              'isServiceReward': true,
              'image': reward.imagePath,
              'imagePath': reward.imagePath,
            });
          }
          break;
        case RewardType.stars:
          // Star packs are usually immediate consumables or separate
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = Provider.of<ProfileProvider>(context);
    final profile = profileProv.activeProfile;

    if (profile == null) {
      return const Scaffold(body: Center(child: Text('Loading profile...')));
    }

    final unlockedList = StorageManager.unlockedRewards;
    final unlockedAchievementsList = StorageManager.unlockedAchievements;

    final equippedHat = StorageManager.equippedHat;
    final equippedTrail = StorageManager.equippedTrail;
    final equippedTheme = StorageManager.equippedTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Wardrobe 🏆'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary500,
          unselectedLabelColor: AppColors.neutral500,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: '👕 Outfits'),
            Tab(text: '🤠 Hats'),
            Tab(text: '🌈 Trails'),
            Tab(text: '🎨 Themes'),
            Tab(text: '🏆 Badges'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- STAT BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: AppCard(
                  variant: AppCardVariant.reward,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/coins/coin_01.png',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Your Coins',
                            style: AppTextStyles.base.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${profile.totalCoins}',
                        style: AppTextStyles.title.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- LIVE PREVIEW AREA ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: _buildLivePreview(
                  profile,
                  equippedHat,
                  equippedTrail,
                  equippedTheme,
                ),
              ),

              const SizedBox(height: 8),

              // --- TAB BAR VIEWS ---
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOutfitsTab(profile, profileProv, unlockedList),
                    _buildHatsTab(
                      profile,
                      profileProv,
                      unlockedList,
                      equippedHat,
                    ),
                    _buildTrailsTab(
                      profile,
                      profileProv,
                      unlockedList,
                      equippedTrail,
                    ),
                    _buildThemesTab(
                      profile,
                      profileProv,
                      unlockedList,
                      equippedTheme,
                    ),
                    _buildAchievementsTab(
                      profile,
                      profileProv,
                      unlockedAchievementsList,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreview(
    ChildProfile profile,
    String selectedHat,
    String selectedTrail,
    String selectedTheme,
  ) {
    final theme = ThemeRewards.getTheme(selectedTheme);
    final themeColor = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (selectedTrail != 'none')
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: selectedTrail == 'rainbow_trail'
                            ? Colors.purple
                            : (selectedTrail == 'star_trail'
                                  ? Colors.amber
                                  : Colors.deepOrange),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              SizedBox(
                height: 75,
                width: 75,
                child: Image.asset(
                  profile.characterImagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: AppColors.neutral400,
                  ),
                ),
              ),
              if (selectedHat != 'none')
                Positioned(
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: selectedHat == 'propeller_hat'
                          ? Colors.red
                          : (selectedHat == 'cowboy_hat'
                                ? Colors.brown
                                : Colors.purple),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      selectedHat == 'propeller_hat'
                          ? '🛸 Prop'
                          : (selectedHat == 'cowboy_hat' ? '🤠 Cow' : '🧙 Wiz'),
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LIVE PREVIEW ✨',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Theme: ${selectedTheme.toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: themeColor,
                ),
              ),
              Text(
                'Trail: ${selectedTrail.toUpperCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.neutral700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitsTab(
    ChildProfile profile,
    ProfileProvider profileProv,
    List<String> unlockedList,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _outfits.length,
      itemBuilder: (context, index) {
        final reward = _outfits[index];
        final key = reward['key'] as String;
        final name = reward['name'] as String;
        final cost = reward['cost'] as int;
        final imagePath = reward['imagePath'] as String;

        final isUnlocked = unlockedList.contains(key);
        final isEquipped = profile.selectedCharacterId == key;

        return _buildItemCard(
          name: name,
          detail: isUnlocked ? 'Unlocked ✅' : 'Available in Shop',
          image: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/reward/dummy_reward.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.checkroom_rounded,
                color: AppColors.primary300,
              ),
            ),
          ),
          isEquipped: isEquipped,
          isUnlocked: isUnlocked,
          onEquip: () async {
            await profileProv.updateCharacter(key);
            setState(() {});
          },
          onUnlock: profile.totalCoins >= cost
              ? () async {
                  final updated = profile.copyWith(
                    totalCoins: profile.totalCoins - cost,
                  );
                  await StorageManager.saveChildProfile(updated);
                  await StorageManager.unlockReward(key);
                  profileProv.loadProfile();
                  setState(() {});
                }
              : null,
          trailingWidget: (!isUnlocked && cost > 0)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$cost',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset('assets/images/coins/coin_01.png', width: 24),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildHatsTab(
    ChildProfile profile,
    ProfileProvider profileProv,
    List<String> unlockedList,
    String equippedHat,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hats.length,
      itemBuilder: (context, index) {
        final hat = _hats[index];
        final key = hat['key'] as String;
        final name = hat['name'] as String;
        final cost = hat['cost'] as int;
        final isUnlocked = key == 'none' || unlockedList.contains('hat_$key');
        final isEquipped = equippedHat == key;

        return _buildItemCard(
          name: name,
          detail: isUnlocked ? 'Unlocked ✅' : 'Classic Accessory',
          image: Image.asset(
            'assets/images/reward/dummy_reward.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Text(
                key == 'none' ? '❌' :
                key == 'propeller_hat' ? '🛸' :
                key == 'cowboy_hat' ? '🤠' : '🧙',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          isEquipped: isEquipped,
          isUnlocked: isUnlocked,
          onEquip: () async {
            await StorageManager.setEquippedHat(key);
            setState(() {});
          },
          onUnlock: profile.totalCoins >= cost
              ? () async {
                  final updated = profile.copyWith(
                    totalCoins: profile.totalCoins - cost,
                  );
                  await StorageManager.saveChildProfile(updated);
                  await StorageManager.unlockReward('hat_$key');
                  profileProv.loadProfile();
                  setState(() {});
                }
              : null,
          trailingWidget: (!isUnlocked && cost > 0)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$cost',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset('assets/images/coins/coin_01.png', width: 24),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildTrailsTab(
    ChildProfile profile,
    ProfileProvider profileProv,
    List<String> unlockedList,
    String equippedTrail,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trails.length,
      itemBuilder: (context, index) {
        final trail = _trails[index];
        final key = trail['key'] as String;
        final name = trail['name'] as String;
        final cost = trail['cost'] as int;
        final isUnlocked = key == 'none' || unlockedList.contains('trail_$key');
        final isEquipped = equippedTrail == key;

        return _buildItemCard(
          name: name,
          detail: isUnlocked ? 'Unlocked ✅' : 'Visual Effect',
          image: Image.asset(
            'assets/images/reward/dummy_reward.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Text(
                key == 'none' ? '❌' :
                key == 'sparkle' ? '✨' :
                key == 'rainbow' ? '🌈' : '💨',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          isEquipped: isEquipped,
          isUnlocked: isUnlocked,
          onEquip: () async {
            await StorageManager.setEquippedTrail(key);
            setState(() {});
          },
          onUnlock: profile.totalCoins >= cost
              ? () async {
                  final updated = profile.copyWith(
                    totalCoins: profile.totalCoins - cost,
                  );
                  await StorageManager.saveChildProfile(updated);
                  await StorageManager.unlockReward('trail_$key');
                  profileProv.loadProfile();
                  setState(() {});
                }
              : null,
          trailingWidget: (!isUnlocked && cost > 0)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$cost',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset('assets/images/coins/coin_01.png', width: 24),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildThemesTab(
    ChildProfile profile,
    ProfileProvider profileProv,
    List<String> unlockedList,
    String equippedTheme,
  ) {
    final unlockedThemes = StorageManager.unlockedThemes;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _themes.length,
      itemBuilder: (context, index) {
        final theme = _themes[index];
        final isUnlocked = unlockedThemes.contains(theme.key);
        final isEquipped = equippedTheme == theme.key;

        String unlockDesc = '';
        switch (theme.unlockType) {
          case ThemeUnlockType.level:
            unlockDesc = 'Complete Level ${theme.unlockValue}';
            break;
          case ThemeUnlockType.streak:
            unlockDesc = 'Reach ${theme.unlockValue} day streak';
            break;
          case ThemeUnlockType.coins:
            unlockDesc = '${theme.unlockValue} coins to unlock';
            break;
          case ThemeUnlockType.defaultUnlocked:
            unlockDesc = 'Unlocked ✅';
            break;
        }

        return _buildItemCard(
          name: theme.name,
          detail: isUnlocked ? 'Unlocked ✅' : unlockDesc,
          image: Container(
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: theme.primaryColor, width: 2),
            ),
            child: Center(
              child: Text(
                theme.iconEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          isEquipped: isEquipped,
          isUnlocked: isUnlocked,
          onEquip: () async {
            await StorageManager.setEquippedTheme(theme.key);
            setState(() {});
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Theme "${theme.name}" equipped!'),
                  backgroundColor: theme.primaryColor,
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          onUnlock: null, // Unlocked via progression/coins automatically
          trailingWidget: !isUnlocked
              ? const Icon(Icons.lock_rounded, color: AppColors.neutral400)
              : null,
        );
      },
    );
  }

  Widget _buildAchievementsTab(
    ChildProfile profile,
    ProfileProvider profileProv,
    List<String> unlockedAchievementsList,
  ) {
    final unlockedRewards = StorageManager.unlockedRewards;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final ach = _achievements[index];
        final key = ach['key'] as String;
        final name = ach['name'] as String;
        final desc = ach['desc'] as String;
        final reward = ach['reward'] as int;
        final isServiceReward = ach['isServiceReward'] == true;
        final imagePath = ach['imagePath'] as String?;

        final isUnlocked = isServiceReward 
            ? unlockedRewards.contains(key)
            : unlockedAchievementsList.contains(key);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AppCard(
            variant: isUnlocked
                ? AppCardVariant.selected
                : AppCardVariant.defaultCard,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? Colors.amber.withValues(alpha: 0.15)
                        : Colors.amber.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isServiceReward && imagePath != null
                        ? Opacity(
                            opacity: isUnlocked ? 1.0 : 0.5,
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Text(
                                isUnlocked ? '🥇' : '🔒',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          )
                        : Text(
                            isUnlocked ? '🥇' : '🔒',
                            style: const TextStyle(fontSize: 20),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: AppTextStyles.primaryFont,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isUnlocked
                              ? AppColors.neutral900
                              : AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.primaryFont,
                          fontSize: 12,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isServiceReward)
                  Builder(builder: (context) {
                    final claimedList = StorageManager.claimedAchievements;
                    final isClaimed = claimedList.contains(key);

                    return GestureDetector(
                      onTap: (isUnlocked && !isClaimed)
                          ? () async {
                              final updated = profile.copyWith(
                                totalCoins: profile.totalCoins + reward,
                              );
                              await StorageManager.saveChildProfile(updated);
                              await StorageManager.claimAchievement(key);
                              profileProv.loadProfile();
                              setState(() {});
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Claimed $reward coins! ✨'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isClaimed
                              ? AppColors.neutral200
                              : (isUnlocked
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.neutral100),
                          borderRadius: BorderRadius.circular(8),
                          border: (isUnlocked && !isClaimed)
                              ? Border.all(color: AppColors.success, width: 1)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isClaimed ? 'Claimed' : '+$reward',
                              style: TextStyle(
                                fontFamily: AppTextStyles.primaryFont,
                                fontWeight: FontWeight.bold,
                                color: isClaimed
                                    ? AppColors.neutral500
                                    : (isUnlocked
                                        ? AppColors.success
                                        : AppColors.neutral600),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Image.asset(
                              'assets/images/coins/coin_01.png',
                              width: 16,
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  })
                else if (isUnlocked)
                  const Icon(Icons.check_circle_rounded, color: AppColors.success),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemCard({
    required String name,
    required String detail,
    required Widget image,
    required bool isEquipped,
    required bool isUnlocked,
    required VoidCallback onEquip,
    required VoidCallback? onUnlock,
    Widget? trailingWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        variant: isEquipped
            ? AppCardVariant.selected
            : AppCardVariant.defaultCard,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              height: 56,
              width: 56,
              decoration: const BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  Opacity(
                    opacity: isUnlocked ? 1.0 : 0.6,
                    child: image,
                  ),
                  if (!isUnlocked)
                    const Center(
                      child: Icon(Icons.lock_rounded, color: Colors.white70),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.primaryFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.primaryFont,
                      fontSize: 13,
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingWidget != null) ...[
              trailingWidget,
              const SizedBox(width: 8),
            ],
            if (isEquipped)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Equipped 🌟',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            else if (isUnlocked)
              AppButton(
                label: 'EQUIP',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.secondary,
                onPressed: onEquip,
              )
            else
              AppButton(
                label: 'UNLOCK',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.primary,
                onPressed: onUnlock,
              ),
          ],
        ),
      ),
    );
  }
}
