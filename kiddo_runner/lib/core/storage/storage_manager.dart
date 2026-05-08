import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/child_profile.dart';
import '../../models/level_progress.dart';
import '../../models/question.dart';
import '../../models/game_session.dart';
import '../../models/mistake_history.dart';

class StorageManager {
  static late SharedPreferences _prefs;
  static late Box _profileBox;
  static late Box _progressBox;
  static late Box _questionBox;
  static late Box _sessionBox;
  static late Box _mistakeBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    _prefs = await SharedPreferences.getInstance();

    _profileBox = await Hive.openBox('child_profiles');
    _progressBox = await Hive.openBox('level_progress');
    _questionBox = await Hive.openBox('questions');
    _sessionBox = await Hive.openBox('game_sessions');
    _mistakeBox = await Hive.openBox('mistake_history');

    await _seedQuestionBank();
  }

  // SharedPreferences Keys
  static bool get soundEnabled => _prefs.getBool('sound_enabled') ?? true;
  static Future<void> setSoundEnabled(bool val) =>
      _prefs.setBool('sound_enabled', val);

  static bool get musicEnabled => _prefs.getBool('music_enabled') ?? true;
  static Future<void> setMusicEnabled(bool val) =>
      _prefs.setBool('music_enabled', val);

  static int get dailyPlayLimitMinutes =>
      _prefs.getInt('daily_play_limit_minutes') ?? 15;
  static Future<void> setDailyPlayLimitMinutes(int val) =>
      _prefs.setInt('daily_play_limit_minutes', val);

  static int get dailyPlayTimeSeconds =>
      _prefs.getInt('daily_play_time_seconds') ?? 0;
  static Future<void> setDailyPlayTimeSeconds(int val) =>
      _prefs.setInt('daily_play_time_seconds', val);

  static int get extraPlayMinutesToday =>
      _prefs.getInt('extra_play_minutes_today') ?? 0;

  static bool get isExtraPlayUsedToday =>
      _prefs.getBool('extra_play_extension_used') ?? false;

  static String get extraPlayExtensionDate =>
      _prefs.getString('extra_play_extension_date') ?? '';

  static Future<void> addExtraPlayMinutesToday(int minutes) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _prefs.setInt(
      'extra_play_minutes_today',
      extraPlayMinutesToday + minutes,
    );
    await _prefs.setBool('extra_play_extension_used', true);
    await _prefs.setString('extra_play_extension_date', today);
  }

  static Future<void> resetExtraPlayIfNewDay() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final storedDate = extraPlayExtensionDate;
    if (storedDate != today) {
      await _prefs.setInt('extra_play_minutes_today', 0);
      await _prefs.setBool('extra_play_extension_used', false);
      await _prefs.setString('extra_play_extension_date', today);
    }
  }

  static int get effectiveDailyPlayLimitMinutes =>
      dailyPlayLimitMinutes + extraPlayMinutesToday;

  static List<String> get unlockedRewards =>
      _prefs.getStringList('unlocked_rewards') ?? ['default_runner'];
  static Future<void> unlockReward(String key) async {
    final list = List<String>.from(unlockedRewards);
    if (!list.contains(key)) {
      list.add(key);
      await _prefs.setStringList('unlocked_rewards', list);
    }
  }

  // Streaks, Daily Rewards, Cosmetics & Achievements
  static String get lastDailyClaimDate =>
      _prefs.getString('last_daily_claim_date') ?? '';
  static Future<void> setLastDailyClaimDate(String date) =>
      _prefs.setString('last_daily_claim_date', date);

  static int get dailyStreakCount => _prefs.getInt('daily_streak_count') ?? 0;
  static Future<void> setDailyStreakCount(int val) =>
      _prefs.setInt('daily_streak_count', val);

  static String get lastActiveDate =>
      _prefs.getString('last_active_date') ?? '';
  static Future<void> setLastActiveDate(String date) =>
      _prefs.setString('last_active_date', date);

  static int get playStreak => _prefs.getInt('play_streak') ?? 0;
  static Future<void> setPlayStreak(int val) =>
      _prefs.setInt('play_streak', val);

  static List<String> get unlockedAchievements =>
      _prefs.getStringList('unlocked_achievements') ?? [];
  static Future<void> unlockAchievement(String id) async {
    final list = List<String>.from(unlockedAchievements);
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList('unlocked_achievements', list);
    }
  }

  static List<String> get claimedAchievements =>
      _prefs.getStringList('claimed_achievements') ?? [];
  static Future<void> claimAchievement(String id) async {
    final list = List<String>.from(claimedAchievements);
    if (!list.contains(id)) {
      list.add(id);
      await _prefs.setStringList('claimed_achievements', list);
    }
  }

  static String get equippedSkin =>
      _prefs.getString('equipped_skin') ?? 'default_runner';
  static Future<void> setEquippedSkin(String val) =>
      _prefs.setString('equipped_skin', val);

  static String get equippedHat => _prefs.getString('equipped_hat') ?? 'none';
  static Future<void> setEquippedHat(String val) =>
      _prefs.setString('equipped_hat', val);

  static String get equippedTrail =>
      _prefs.getString('equipped_trail') ?? 'none';
  static Future<void> setEquippedTrail(String val) =>
      _prefs.setString('equipped_trail', val);

  static String get equippedTheme =>
      _prefs.getString('equipped_theme') ?? 'blue';

  static Future<void> setEquippedTheme(String val) async {
    if (isThemeUnlocked(val)) {
      await _prefs.setString('equipped_theme', val);
    }
  }

  static List<String> get unlockedThemes =>
      _prefs.getStringList('unlocked_themes') ?? ['blue'];

  static Future<void> unlockTheme(String themeKey) async {
    final list = List<String>.from(unlockedThemes);
    if (!list.contains(themeKey)) {
      list.add(themeKey);
      await _prefs.setStringList('unlocked_themes', list);
    }
  }

  static bool isThemeUnlocked(String themeKey) {
    if (themeKey == 'blue') return true;
    return unlockedThemes.contains(themeKey);
  }

  // Child Profile Hive Transactions
  static ChildProfile? getChildProfile() {
    dynamic map = _profileBox.get('active_profile');
    if (map == null && _profileBox.isNotEmpty) {
      try {
        map = _profileBox.getAt(0);
      } catch (_) {
        map = null;
      }
      if (map != null) {
        _profileBox.put('active_profile', map);
      }
    }
    if (map == null) return null;
    try {
      return ChildProfile.fromMap(Map<dynamic, dynamic>.from(map));
    } catch (e) {
      debugPrint('Error parsing profile: $e');
      return null;
    }
  }

  static Future<void> saveChildProfile(ChildProfile profile) async {
    await _profileBox.put('active_profile', profile.toMap());
  }

  // Level Progression Hive Transactions
  static List<LevelProgress> getLevelProgressList() {
    return _progressBox.values
        .map((e) => LevelProgress.fromMap(Map<dynamic, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.levelNumber.compareTo(b.levelNumber));
  }

  static Future<void> saveLevelProgress(LevelProgress progress) async {
    await _progressBox.put(
      'level_${progress.mode}_${progress.levelNumber}',
      progress.toMap(),
    );
  }

  // Questions Hive Transactions
  static List<Question> getQuestionsForAgeGroup(String ageGroup, String mode) {
    return _questionBox.values
        .map((e) => Question.fromMap(Map<dynamic, dynamic>.from(e)))
        .where((q) => q.ageGroup == ageGroup && q.mode == mode)
        .toList();
  }

  // Game Sessions Hive Transactions
  static List<GameSession> getGameSessions() {
    return _sessionBox.values
        .map((e) => GameSession.fromMap(Map<dynamic, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveGameSession(GameSession session) async {
    await _sessionBox.add(session.toMap());
  }

  // Mistake History Hive Transactions
  static List<MistakeHistory> getMistakes() {
    return _mistakeBox.values
        .map((e) => MistakeHistory.fromMap(Map<dynamic, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveMistake(MistakeHistory mistake) async {
    await _mistakeBox.add(mistake.toMap());
  }

  static Future<void> clearAllData() async {
    await _profileBox.clear();
    await _progressBox.clear();
    await _sessionBox.clear();
    await _mistakeBox.clear();
    await _questionBox.clear();
    await _prefs.clear();
    await _prefs.setStringList('unlocked_themes', ['blue']);
    await _prefs.setString('equipped_theme', 'blue');
    await _seedQuestionBank();
    await setSoundEnabled(true);
    await setMusicEnabled(true);
    await setDailyPlayLimitMinutes(15);
    await setDailyPlayTimeSeconds(0);
  }

  static Future<void> _seedQuestionBank() async {
    final List<Question> seed = [];
    final random = Random();

    // Helper to shuffle options and get the correct slot
    void addQuestion({
      required String id,
      required String ageGroup,
      required String mode,
      required String topic,
      required String questionText,
      required String correctVal,
      required String wrong1,
      required String wrong2,
    }) {
      final opts = [correctVal, wrong1, wrong2];
      opts.shuffle(random);
      final optionA = opts[0];
      final optionB = opts[1];
      final optionC = opts[2];
      String correctOption = 'A';
      if (optionB == correctVal) correctOption = 'B';
      if (optionC == correctVal) correctOption = 'C';

      seed.add(
        Question(
          id: id,
          ageGroup: ageGroup,
          mode: mode,
          topic: topic,
          questionText: questionText,
          optionA: optionA,
          optionB: optionB,
          optionC: optionC,
          correctOption: correctOption,
        ),
      );
    }

    // --- MATH AGE 4-5 ---
    final Set<String> math45AddUsed = {};
    int count45Add = 1;
    while (count45Add <= 20) {
      final a = random.nextInt(5) + 1;
      final b = random.nextInt(5) + 1;
      final text = '$a + $b = ?';
      if (!math45AddUsed.contains(text)) {
        math45AddUsed.add(text);
        final correct = a + b;
        addQuestion(
          id: 'seed_m_4_5_add_$count45Add',
          ageGroup: '4-5',
          mode: 'math',
          topic: 'addition_under_10',
          questionText: text,
          correctVal: '$correct',
          wrong1: '${correct + 1}',
          wrong2: '${correct > 1 ? correct - 1 : correct + 2}',
        );
        count45Add++;
      }
    }

    for (int i = 1; i <= 15; i++) {
      final count = (i % 5) + 1;
      final stars = '⭐' * count;
      addQuestion(
        id: 'seed_m_4_5_cnt_$i',
        ageGroup: '4-5',
        mode: 'math',
        topic: 'counting_1_to_5',
        questionText: 'Count stars: $stars',
        correctVal: '$count',
        wrong1: '${count == 1 ? 5 : count - 1}',
        wrong2: '${count + 1}',
      );
    }

    // --- MATH AGE 6-7 ---
    final Set<String> math67AddUsed = {};
    int count67Add = 1;
    while (count67Add <= 25) {
      final a = random.nextInt(10) + 5;
      final b = random.nextInt(10) + 2;
      final text = '$a + $b = ?';
      if (!math67AddUsed.contains(text)) {
        math67AddUsed.add(text);
        final correct = a + b;
        addQuestion(
          id: 'seed_m_6_7_add_$count67Add',
          ageGroup: '6-7',
          mode: 'math',
          topic: 'addition_under_20',
          questionText: text,
          correctVal: '$correct',
          wrong1: '${correct - 2}',
          wrong2: '${correct + 2}',
        );
        count67Add++;
      }
    }

    final Set<String> math67SubUsed = {};
    int count67Sub = 1;
    while (count67Sub <= 20) {
      final a = random.nextInt(10) + 10;
      final b = random.nextInt(8) + 2;
      final text = '$a - $b = ?';
      if (!math67SubUsed.contains(text)) {
        math67SubUsed.add(text);
        final correct = a - b;
        addQuestion(
          id: 'seed_m_6_7_sub_$count67Sub',
          ageGroup: '6-7',
          mode: 'math',
          topic: 'subtraction_under_20',
          questionText: text,
          correctVal: '$correct',
          wrong1: '${correct + 1}',
          wrong2: '${correct - 1 < 0 ? correct + 2 : correct - 1}',
        );
        count67Sub++;
      }
    }

    // --- MATH AGE 8-10 ---
    final Set<String> math810MulUsed = {};
    int count810Mul = 1;
    while (count810Mul <= 25) {
      final a = random.nextInt(8) + 2;
      final b = random.nextInt(8) + 2;
      final text = '$a x $b = ?';
      if (!math810MulUsed.contains(text)) {
        math810MulUsed.add(text);
        final correct = a * b;
        addQuestion(
          id: 'seed_m_8_10_mul_$count810Mul',
          ageGroup: '8-10',
          mode: 'math',
          topic: 'multiplication_2_9',
          questionText: text,
          correctVal: '$correct',
          wrong1: '${correct - 2}',
          wrong2: '${correct + 3}',
        );
        count810Mul++;
      }
    }

    final Set<String> math810DivUsed = {};
    int count810Div = 1;
    while (count810Div <= 20) {
      final b = random.nextInt(8) + 2;
      final correct = random.nextInt(8) + 2;
      final a = correct * b;
      final text = '$a / $b = ?';
      if (!math810DivUsed.contains(text)) {
        math810DivUsed.add(text);
        addQuestion(
          id: 'seed_m_8_10_div_$count810Div',
          ageGroup: '8-10',
          mode: 'math',
          topic: 'division_easy',
          questionText: text,
          correctVal: '$correct',
          wrong1: '${correct + 1}',
          wrong2: '${correct - 1 <= 0 ? correct + 2 : correct - 1}',
        );
        count810Div++;
      }
    }

    // --- SPELLING AGE 4-5 ---
    final List<String> words45 = [
      'CAT',
      'DOG',
      'BUS',
      'SUN',
      'TOY',
      'PIG',
      'HAT',
      'BOX',
      'BED',
      'RUN',
      'SAD',
      'RED',
      'COW',
      'BAT',
      'CUP',
    ];
    for (int i = 0; i < words45.length; i++) {
      final word = words45[i];
      final firstLetter = word[0];

      // Random wrong letters
      final alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
      alphabet.remove(firstLetter);
      alphabet.shuffle(random);

      addQuestion(
        id: 'seed_s_4_5_$i',
        ageGroup: '4-5',
        mode: 'spelling',
        topic: 'letter_recognition',
        questionText: 'What letter starts "$word"?',
        correctVal: firstLetter,
        wrong1: alphabet[0],
        wrong2: alphabet[1],
      );
    }

    // --- SPELLING AGE 6-7 ---
    final List<Map<String, dynamic>> words67 = [
      {
        'word': 'TREE',
        'options': ['TREE', 'TREA', 'TRE'],
        'correct': 0,
      },
      {
        'word': 'BIRD',
        'options': ['BURD', 'BIRD', 'BRID'],
        'correct': 1,
      },
      {
        'word': 'FROG',
        'options': ['FRUG', 'FORG', 'FROG'],
        'correct': 2,
      },
      {
        'word': 'DUCK',
        'options': ['DUCK', 'DUK', 'DUX'],
        'correct': 0,
      },
      {
        'word': 'FISH',
        'options': ['FICH', 'FISH', 'FISS'],
        'correct': 1,
      },
      {
        'word': 'LION',
        'options': ['LYON', 'LIUN', 'LION'],
        'correct': 2,
      },
      {
        'word': 'STAR',
        'options': ['STAR', 'STER', 'STA'],
        'correct': 0,
      },
      {
        'word': 'MOON',
        'options': ['MUNE', 'MOON', 'MON'],
        'correct': 1,
      },
      {
        'word': 'BOAT',
        'options': ['BOTE', 'BOUT', 'BOAT'],
        'correct': 2,
      },
      {
        'word': 'CAKE',
        'options': ['CAKE', 'CAK', 'KAKE'],
        'correct': 0,
      },
      {
        'word': 'MILK',
        'options': ['MELK', 'MILK', 'MILC'],
        'correct': 1,
      },
      {
        'word': 'COLD',
        'options': ['COULD', 'CLOD', 'COLD'],
        'correct': 2,
      },
    ];
    for (int i = 0; i < words67.length; i++) {
      final item = words67[i];
      final opts = item['options'] as List<String>;
      final correctVal = opts[item['correct'] as int];
      final wrongOpts = opts.where((e) => e != correctVal).toList();

      addQuestion(
        id: 'seed_s_6_7_$i',
        ageGroup: '6-7',
        mode: 'spelling',
        topic: 'spelling_check',
        questionText: 'Which spelling is correct?',
        correctVal: correctVal,
        wrong1: wrongOpts.isNotEmpty ? wrongOpts[0] : 'AAA',
        wrong2: wrongOpts.length > 1 ? wrongOpts[1] : 'BBB',
      );
    }

    // --- SPELLING AGE 8-10 ---
    final List<Map<String, dynamic>> words810 = [
      {
        'word': 'SCHOOL',
        'options': ['SCHOOL', 'SCOOL', 'SCHUL'],
        'correct': 0,
      },
      {
        'word': 'BANANA',
        'options': ['BANNANA', 'BANANA', 'BANANNA'],
        'correct': 1,
      },
      {
        'word': 'MONKEY',
        'options': ['MUNKEY', 'MONKY', 'MONKEY'],
        'correct': 2,
      },
      {
        'word': 'ORANGE',
        'options': ['ORANGE', 'ORNGE', 'ARANGE'],
        'correct': 0,
      },
      {
        'word': 'PURPLE',
        'options': ['PERPLE', 'PURPLE', 'PURPEL'],
        'correct': 1,
      },
      {
        'word': 'FLOWER',
        'options': ['FLOWR', 'FLOUR', 'FLOWER'],
        'correct': 2,
      },
      {
        'word': 'FRIEND',
        'options': ['FRIEND', 'FREIND', 'FRIND'],
        'correct': 0,
      },
      {
        'word': 'ANIMAL',
        'options': ['ANIMEL', 'ANIMAL', 'ANNIMAL'],
        'correct': 1,
      },
      {
        'word': 'SUMMER',
        'options': ['SUMER', 'SOMMER', 'SUMMER'],
        'correct': 2,
      },
      {
        'word': 'WINTER',
        'options': ['WINTER', 'WINTR', 'WENTER'],
        'correct': 0,
      },
      {
        'word': 'PLANET',
        'options': ['PLANNET', 'PLANET', 'PLENET'],
        'correct': 1,
      },
      {
        'word': 'GUITAR',
        'options': ['GITUR', 'GITAR', 'GUITAR'],
        'correct': 2,
      },
    ];
    for (int i = 0; i < words810.length; i++) {
      final item = words810[i];
      final opts = item['options'] as List<String>;
      final correctVal = opts[item['correct'] as int];
      final wrongOpts = opts.where((e) => e != correctVal).toList();

      addQuestion(
        id: 'seed_s_8_10_$i',
        ageGroup: '8-10',
        mode: 'spelling',
        topic: 'spelling_check_advanced',
        questionText: 'Correct spelling of ${item['word']}?',
        correctVal: correctVal,
        wrong1: wrongOpts.isNotEmpty ? wrongOpts[0] : 'AAA',
        wrong2: wrongOpts.length > 1 ? wrongOpts[1] : 'BBB',
      );
    }

    for (final q in seed) {
      if (!_questionBox.containsKey(q.id)) {
        await _questionBox.put(q.id, q.toMap());
      }
    }
  }
}
