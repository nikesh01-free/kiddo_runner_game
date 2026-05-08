enum RewardType { outfit, cap, shoes, badge, skin, stars }

class RewardItem {
  final String id;
  final String name;
  final RewardType type;
  final String imagePath;
  final String description;
  final bool isUnlocked;
  final bool isEquipped;

  RewardItem({
    required this.id,
    required this.name,
    required this.type,
    required this.imagePath,
    required this.description,
    this.isUnlocked = false,
    this.isEquipped = false,
  });

  RewardItem copyWith({
    bool? isUnlocked,
    bool? isEquipped,
  }) {
    return RewardItem(
      id: id,
      name: name,
      type: type,
      imagePath: imagePath,
      description: description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'imagePath': imagePath,
      'description': description,
      'isUnlocked': isUnlocked,
      'isEquipped': isEquipped,
    };
  }

  factory RewardItem.fromMap(Map<String, dynamic> map) {
    return RewardItem(
      id: map['id'],
      name: map['name'],
      type: RewardType.values.firstWhere((e) => e.name == map['type']),
      imagePath: map['imagePath'],
      description: map['description'] ?? '',
      isUnlocked: map['isUnlocked'] ?? false,
      isEquipped: map['isEquipped'] ?? false,
    );
  }
}
