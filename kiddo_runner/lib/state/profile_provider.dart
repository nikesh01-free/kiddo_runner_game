import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/storage/storage_manager.dart';
import '../models/child_profile.dart';
import '../models/level_progress.dart';
import '../models/game_session.dart';
import '../models/mistake_history.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider() {
    loadProfile();
  }

  ChildProfile? _activeProfile;
  List<LevelProgress> _levelProgressList = [];

  ChildProfile? get activeProfile => _activeProfile;
  List<LevelProgress> get levelProgressList => _levelProgressList;

  void loadProfile() {
    _activeProfile = StorageManager.getChildProfile();
    if (_activeProfile != null) {
      _levelProgressList = StorageManager.getLevelProgressList();
    }
    notifyListeners();
  }

  Future<void> createProfile({
    required String ageGroup,
    required String characterId,
    required String childName,
  }) async {
    final uuid = const Uuid().v4();
    final now = DateTime.now();

    final profile = ChildProfile(
      id: uuid,
      childName: childName,
      ageGroup: ageGroup,
      selectedCharacterId: characterId,
      totalCoins: 0,
      totalStars: 0,
      createdAt: now,
      updatedAt: now,
    );

    await StorageManager.saveChildProfile(profile);

    // Instantiate 20 educational progress levels for both math and spelling
    for (int i = 1; i <= 20; i++) {
      final mathProgress = LevelProgress(
        id: const Uuid().v4(),
        childProfileId: uuid,
        levelNumber: i,
        isUnlocked: i == 1, // level 1 unlocked initially
        isCompleted: false,
        mode: 'math',
        createdAt: now,
        updatedAt: now,
      );
      await StorageManager.saveLevelProgress(mathProgress);

      final spellingProgress = LevelProgress(
        id: const Uuid().v4(),
        childProfileId: uuid,
        levelNumber: i,
        isUnlocked: i == 1, // level 1 unlocked initially
        isCompleted: false,
        mode: 'spelling',
        createdAt: now,
        updatedAt: now,
      );
      await StorageManager.saveLevelProgress(spellingProgress);
    }

    loadProfile();
  }

  Future<void> completeLevel({
    required int levelNumber,
    required int score,
    required int stars,
    required double accuracy,
    required int coins,
    required String mode,
    required List<Map<String, String>> mistakes,
  }) async {
    if (_activeProfile == null) return;

    final now = DateTime.now();

    final currentLvl = _levelProgressList.firstWhere(
      (e) => e.levelNumber == levelNumber && e.mode == mode,
      orElse: () => LevelProgress(
        id: '',
        childProfileId: _activeProfile!.id,
        levelNumber: levelNumber,
        isUnlocked: true,
        isCompleted: false,
        mode: mode,
        createdAt: now,
        updatedAt: now,
      ),
    );

    int actualCoinsGranted = coins;
    int actualStarsGranted = stars;
    if (currentLvl.isCompleted) {
      actualCoinsGranted = 0;
      actualStarsGranted = 0;
    }

    // 1. Update coins and stars inside profile
    var updatedProfile = _activeProfile!.copyWith(
      totalCoins: _activeProfile!.totalCoins + actualCoinsGranted,
      totalStars: _activeProfile!.totalStars + actualStarsGranted,
      updatedAt: now,
    );
    await StorageManager.saveChildProfile(updatedProfile);

    // 2. Archive active game session
    final session = GameSession(
      id: const Uuid().v4(),
      childProfileId: _activeProfile!.id,
      levelNumber: levelNumber,
      mode: mode,
      score: score,
      stars: stars,
      accuracy: accuracy,
      coinsEarned: actualCoinsGranted,
      createdAt: now,
    );
    await StorageManager.saveGameSession(session);

    // 3. Archive mistakes for focus metrics
    for (final m in mistakes) {
      final mistake = MistakeHistory(
        id: const Uuid().v4(),
        childProfileId: _activeProfile!.id,
        questionText: m['question'] ?? '',
        selectedAnswer: m['selected'] ?? '',
        correctAnswer: m['correct'] ?? '',
        mode: mode,
        createdAt: now,
      );
      await StorageManager.saveMistake(mistake);
    }

    final updatedCurrent = currentLvl.copyWith(
      isCompleted: true,
      bestScore: score > currentLvl.bestScore ? score : currentLvl.bestScore,
      bestStars: stars > currentLvl.bestStars ? stars : currentLvl.bestStars,
      updatedAt: now,
    );
    await StorageManager.saveLevelProgress(updatedCurrent);

    if (levelNumber < 20) {
      final nextLvl = _levelProgressList.firstWhere(
        (e) => e.levelNumber == levelNumber + 1 && e.mode == mode,
        orElse: () => LevelProgress(
          id: '',
          childProfileId: _activeProfile!.id,
          levelNumber: levelNumber + 1,
          isUnlocked: false,
          isCompleted: false,
          mode: mode,
          createdAt: now,
          updatedAt: now,
        ),
      );
      if (!nextLvl.isUnlocked && stars >= 1) {
        final updatedNext = nextLvl.copyWith(isUnlocked: true, updatedAt: now);
        await StorageManager.saveLevelProgress(updatedNext);
      }
    }

    // --- Achievements Checks ---
    final listAch = StorageManager.unlockedAchievements;
    final profileForAch = StorageManager.getChildProfile() ?? updatedProfile;

    if (!listAch.contains('first_run')) {
      await StorageManager.unlockAchievement('first_run');
      final p = profileForAch.copyWith(
        totalCoins: profileForAch.totalCoins + 20,
      );
      await StorageManager.saveChildProfile(p);
    }

    if (stars == 3 && !listAch.contains('perfect_level')) {
      await StorageManager.unlockAchievement('perfect_level');
      final curP = StorageManager.getChildProfile() ?? profileForAch;
      final p = curP.copyWith(totalCoins: curP.totalCoins + 50);
      await StorageManager.saveChildProfile(p);
    }

    if (mistakes.isEmpty && !listAch.contains('no_mistakes')) {
      await StorageManager.unlockAchievement('no_mistakes');
      final curP = StorageManager.getChildProfile() ?? profileForAch;
      final p = curP.copyWith(totalCoins: curP.totalCoins + 75);
      await StorageManager.saveChildProfile(p);
    }

    if (mode == 'math' &&
        levelNumber >= 10 &&
        !listAch.contains('math_master')) {
      await StorageManager.unlockAchievement('math_master');
      final curP = StorageManager.getChildProfile() ?? profileForAch;
      final p = curP.copyWith(totalCoins: curP.totalCoins + 100);
      await StorageManager.saveChildProfile(p);
    }

    if (mode == 'spelling' &&
        levelNumber >= 10 &&
        !listAch.contains('word_wizard')) {
      await StorageManager.unlockAchievement('word_wizard');
      final curP = StorageManager.getChildProfile() ?? profileForAch;
      final p = curP.copyWith(totalCoins: curP.totalCoins + 100);
      await StorageManager.saveChildProfile(p);
    }

    final finalP = StorageManager.getChildProfile() ?? profileForAch;
    if (finalP.totalCoins >= 100 && !listAch.contains('100_coins')) {
      await StorageManager.unlockAchievement('100_coins');
      final curP = StorageManager.getChildProfile() ?? finalP;
      final p = curP.copyWith(totalCoins: curP.totalCoins + 50);
      await StorageManager.saveChildProfile(p);
    }

    // --- Theme Unlocks ---
    if (levelNumber >= 1) await StorageManager.unlockTheme('candy');
    if (levelNumber >= 3) await StorageManager.unlockTheme('space');
    if (levelNumber >= 5) await StorageManager.unlockTheme('dino');
    if (levelNumber >= 7) await StorageManager.unlockTheme('ocean');
    if (levelNumber >= 10) await StorageManager.unlockTheme('robot');

    final updatedFinalP = StorageManager.getChildProfile() ?? finalP;
    final streak = StorageManager.playStreak;
    if (streak >= 7 || updatedFinalP.totalCoins >= 500) {
      await StorageManager.unlockTheme('rainbow');
    }

    loadProfile();
  }

  Future<void> updateCharacter(String characterId) async {
    if (_activeProfile == null) return;
    final updated = _activeProfile!.copyWith(
      selectedCharacterId: characterId,
      updatedAt: DateTime.now(),
    );
    await StorageManager.saveChildProfile(updated);
    loadProfile();
  }

  double getAverageMathAccuracy() {
    final sessions = StorageManager.getGameSessions().where(
      (s) => s.mode == 'math',
    );
    if (sessions.isEmpty) return 100.0;
    final total = sessions.map((e) => e.accuracy).reduce((a, b) => a + b);
    return total / sessions.length;
  }

  double getAverageSpellingAccuracy() {
    final sessions = StorageManager.getGameSessions().where(
      (s) => s.mode == 'spelling',
    );
    if (sessions.isEmpty) return 100.0;
    final total = sessions.map((e) => e.accuracy).reduce((a, b) => a + b);
    return total / sessions.length;
  }

  String getWeakTopic() {
    final mistakes = StorageManager.getMistakes();
    if (mistakes.isEmpty) return 'No mistakes registered yet! Great work!';

    // Tally wrong answers
    final tallies = <String, int>{};
    for (final m in mistakes) {
      final text = m.questionText;
      tallies[text] = (tallies[text] ?? 0) + 1;
    }

    final sorted = tallies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  Future<void> resetAllProgress() async {
    await StorageManager.clearAllData();
    _activeProfile = null;
    _levelProgressList = [];
    notifyListeners();
  }
}
