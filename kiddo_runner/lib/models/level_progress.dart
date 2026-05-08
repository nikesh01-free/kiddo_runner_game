class LevelProgress {
  LevelProgress({
    required this.id,
    required this.childProfileId,
    required this.levelNumber,
    required this.isUnlocked,
    required this.isCompleted,
    required this.mode,
    this.bestScore = 0,
    this.bestStars = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String childProfileId;
  final int levelNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final String mode; // math or spelling
  final int bestScore;
  final int bestStars;
  final DateTime createdAt;
  final DateTime updatedAt;

  LevelProgress copyWith({
    String? id,
    String? childProfileId,
    int? levelNumber,
    bool? isUnlocked,
    bool? isCompleted,
    String? mode,
    int? bestScore,
    int? bestStars,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LevelProgress(
      id: id ?? this.id,
      childProfileId: childProfileId ?? this.childProfileId,
      levelNumber: levelNumber ?? this.levelNumber,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      mode: mode ?? this.mode,
      bestScore: bestScore ?? this.bestScore,
      bestStars: bestStars ?? this.bestStars,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_profile_id': childProfileId,
      'level_number': levelNumber,
      'is_unlocked': isUnlocked,
      'is_completed': isCompleted,
      'mode': mode,
      'best_score': bestScore,
      'best_stars': bestStars,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LevelProgress.fromMap(Map<dynamic, dynamic> map) {
    final stars = map['best_stars'] as int? ?? 0;
    final level = map['level_number'] as int? ?? 1;
    final score = map['best_score'] as int? ?? 0;
    return LevelProgress(
      id: map['id'] as String? ?? '',
      childProfileId: map['child_profile_id'] as String? ?? '',
      levelNumber: level.clamp(1, 20),
      isUnlocked: map['is_unlocked'] as bool? ?? false,
      isCompleted: map['is_completed'] as bool? ?? false,
      mode: map['mode'] as String? ?? 'math',
      bestScore: score >= 0 ? score : 0,
      bestStars: stars.clamp(0, 3),
      createdAt: DateTime.parse(
        map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
