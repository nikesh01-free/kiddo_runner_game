class ChildProfile {
  ChildProfile({
    required this.id,
    required this.childName,
    required this.ageGroup,
    required this.selectedCharacterId,
    required this.totalCoins,
    required this.totalStars,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String childName;
  final String ageGroup;
  final String selectedCharacterId;
  final int totalCoins;
  final int totalStars;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get characterImagePath {
    switch (selectedCharacterId) {
      case 'boy':
      case 'default_runner':
        return 'assets/images/characters/kenney_toon-characters/Male adventurer/PNG/Poses HD/character_maleAdventurer_idle.png';
      case 'girl':
        return 'assets/images/characters/kenney_toon-characters/Female adventurer/PNG/Poses HD/character_femaleAdventurer_idle.png';
      case 'ninja_outfit':
        return 'assets/images/characters/kenney_toon-characters/Male person/PNG/Poses HD/character_malePerson_idle.png';
      case 'super_star':
        return 'assets/images/characters/kenney_toon-characters/Robot/PNG/Poses HD/character_robot_idle.png';
      case 'zombie':
        return 'assets/images/characters/kenney_toon-characters/Zombie/PNG/Poses HD/character_zombie_idle.png';
      case 'female_person':
        return 'assets/images/characters/kenney_toon-characters/Female person/PNG/Poses HD/character_femalePerson_idle.png';
      default:
        return 'assets/images/characters/kenney_toon-characters/Male adventurer/PNG/Poses HD/character_maleAdventurer_idle.png';
    }
  }

  ChildProfile copyWith({
    String? id,
    String? childName,
    String? ageGroup,
    String? selectedCharacterId,
    int? totalCoins,
    int? totalStars,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      childName: childName ?? this.childName,
      ageGroup: ageGroup ?? this.ageGroup,
      selectedCharacterId: selectedCharacterId ?? this.selectedCharacterId,
      totalCoins: totalCoins ?? this.totalCoins,
      totalStars: totalStars ?? this.totalStars,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_name': childName,
      'age_group': ageGroup,
      'selected_character_id': selectedCharacterId,
      'total_coins': totalCoins,
      'total_stars': totalStars,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ChildProfile.fromMap(Map<dynamic, dynamic> map) {
    final coins = map['total_coins'] as int? ?? 0;
    final stars = map['total_stars'] as int? ?? 0;
    return ChildProfile(
      id: map['id'] as String? ?? '',
      childName: map['child_name'] as String? ?? 'Adventurer',
      ageGroup: map['age_group'] as String? ?? '4-5',
      selectedCharacterId:
          map['selected_character_id'] as String? ?? 'default_runner',
      totalCoins: coins >= 0 ? coins : 0,
      totalStars: stars >= 0 ? stars : 0,
      createdAt: DateTime.parse(
        map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
