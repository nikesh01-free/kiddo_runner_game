class GameSession {
  GameSession({
    required this.id,
    required this.childProfileId,
    required this.levelNumber,
    required this.mode,
    required this.score,
    required this.stars,
    required this.accuracy,
    required this.coinsEarned,
    required this.createdAt,
  });

  final String id;
  final String childProfileId;
  final int levelNumber;
  final String mode;
  final int score;
  final int stars;
  final double accuracy;
  final int coinsEarned;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_profile_id': childProfileId,
      'level_number': levelNumber,
      'mode': mode,
      'score': score,
      'stars': stars,
      'accuracy': accuracy,
      'coins_earned': coinsEarned,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory GameSession.fromMap(Map<dynamic, dynamic> map) {
    return GameSession(
      id: map['id'] as String,
      childProfileId: map['child_profile_id'] as String,
      levelNumber: map['level_number'] as int,
      mode: map['mode'] as String,
      score: map['score'] as int,
      stars: map['stars'] as int,
      accuracy: (map['accuracy'] as num).toDouble(),
      coinsEarned: map['coins_earned'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
