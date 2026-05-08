import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../state/profile_provider.dart';
import '../core/storage/storage_manager.dart';
import '../models/child_profile.dart';

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
    {'key': 'none', 'name': 'No Hat', 'cost': 0, 'icon': '❌'},
    {
      'key': 'propeller_hat',
      'name': '🛸 Propeller Hat',
      'cost': 20,
      'icon': '🛸',
    },
    {'key': 'cowboy_hat', 'name': '🤠 Cowboy Hat', 'cost': 40, 'icon': '🤠'},
    {'key': 'wizard_hat', 'name': '🧙 Wizard Hat', 'cost': 60, 'icon': '🧙'},
  ];

  final List<Map<String, dynamic>> _trails = [
    {'key': 'none', 'name': 'No Trail', 'cost': 0, 'icon': '❌'},
    {
      'key': 'rainbow_trail',
      'name': '🌈 Rainbow Trail',
      'cost': 30,
      'icon': '🌈',
    },
    {'key': 'star_trail', 'name': '⭐ Star Trail', 'cost': 50, 'icon': '⭐'},
    {'key': 'fire_trail', 'name': '🔥 Fire Trail', 'cost': 70, 'icon': '🔥'},
  ];

  final List<Map<String, dynamic>> _themes = [
    {'key': 'blue', 'name': 'Sky Blue Theme', 'cost': 0, 'color': Colors.blue},
    {
      'key': 'pink',
      'name': 'Candy Pink Theme',
      'cost': 30,
      'color': Colors.pink,
    },
    {
      'key': 'green',
      'name': 'Forest Green Theme',
      'cost': 40,
      'color': Colors.green,
    },
    {
      'key': 'gold',
      'name': 'Golden Crown Theme',
      'cost': 80,
      'color': Colors.amber,
    },
  ];

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
                          const Icon(
                            Icons.monetization_on_rounded,
                            color: AppColors.secondary500,
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Your Coins 🪙',
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
                    _buildAchievementsTab(unlockedAchievementsList),
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
    Color themeColor = Colors.blue;
    if (selectedTheme == 'pink') themeColor = Colors.pink;
    if (selectedTheme == 'green') themeColor = Colors.green;
    if (selectedTheme == 'gold') themeColor = Colors.amber;

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
          detail: isUnlocked ? 'Unlocked ✅' : 'Cost: $cost Coins 🪙',
          image: Image.asset(imagePath, fit: BoxFit.contain),
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
        final icon = hat['icon'] as String;

        final isUnlocked = key == 'none' || unlockedList.contains('hat_$key');
        final isEquipped = equippedHat == key;

        return _buildItemCard(
          name: name,
          detail: isUnlocked ? 'Unlocked ✅' : 'Cost: $cost Coins 🪙',
          image: Center(
            child: Text(icon, style: const TextStyle(fontSize: 32)),
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
        final icon = trail['icon'] as String;

        final isUnlocked = key == 'none' || unlockedList.contains('trail_$key');
        final isEquipped = equippedTrail == key;

        return _buildItemCard(
          name: name,
          detail: isUnlocked ? 'Unlocked ✅' : 'Cost: $cost Coins 🪙',
          image: Center(
            child: Text(icon, style: const TextStyle(fontSize: 32)),
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _themes.length,
      itemBuilder: (context, index) {
        final theme = _themes[index];
        final key = theme['key'] as String;
        final name = theme['name'] as String;
        final cost = theme['cost'] as int;
        final color = theme['color'] as Color;

        final isUnlocked = key == 'blue' || unlockedList.contains('theme_$key');
        final isEquipped = equippedTheme == key;

        return _buildItemCard(
          name: name,
          detail: isUnlocked ? 'Unlocked ✅' : 'Cost: $cost Coins 🪙',
          image: Container(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          isEquipped: isEquipped,
          isUnlocked: isUnlocked,
          onEquip: () async {
            await StorageManager.setEquippedTheme(key);
            setState(() {});
          },
          onUnlock: profile.totalCoins >= cost
              ? () async {
                  final updated = profile.copyWith(
                    totalCoins: profile.totalCoins - cost,
                  );
                  await StorageManager.saveChildProfile(updated);
                  await StorageManager.unlockReward('theme_$key');
                  profileProv.loadProfile();
                  setState(() {});
                }
              : null,
        );
      },
    );
  }

  Widget _buildAchievementsTab(List<String> unlockedAchievementsList) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final ach = _achievements[index];
        final key = ach['key'] as String;
        final name = ach['name'] as String;
        final desc = ach['desc'] as String;
        final reward = ach['reward'] as int;

        final isUnlocked = unlockedAchievementsList.contains(key);

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
                        : AppColors.neutral100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.neutral200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$reward 🪙',
                    style: TextStyle(
                      fontFamily: AppTextStyles.primaryFont,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? AppColors.success
                          : AppColors.neutral600,
                      fontSize: 12,
                    ),
                  ),
                ),
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
              child: image,
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
