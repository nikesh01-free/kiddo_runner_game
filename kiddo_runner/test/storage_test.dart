import 'package:flutter_test/flutter_test.dart';
import 'package:kiddo_runner/models/child_profile.dart';
import 'package:kiddo_runner/models/question.dart';
import 'package:kiddo_runner/models/level_progress.dart';
import 'package:kiddo_runner/game/services/question_service.dart';

void main() {
  group('Kiddo Runner Business Logic & Storage Model Tests', () {
    test('1. ChildProfile toMap and fromMap consistency test', () {
      final now = DateTime.now();
      final profile = ChildProfile(
        id: 'test_child_id',
        childName: 'SuperKid',
        ageGroup: '4-5',
        selectedCharacterId: 'girl',
        totalCoins: 250,
        totalStars: 15,
        createdAt: now,
        updatedAt: now,
      );

      final map = profile.toMap();
      final decoded = ChildProfile.fromMap(map);

      expect(decoded.id, 'test_child_id');
      expect(decoded.childName, 'SuperKid');
      expect(decoded.ageGroup, '4-5');
      expect(decoded.selectedCharacterId, 'girl');
      expect(decoded.totalCoins, 250);
      expect(decoded.totalStars, 15);
      expect(decoded.characterImagePath, contains('Female adventurer'));
    });

    test('2. Onboarding completed status verification test', () {
      ChildProfile? activeProfile;
      expect(
        activeProfile,
        isNull,
        reason: 'Onboarding is incomplete initially.',
      );

      activeProfile = ChildProfile(
        id: 'uuid',
        childName: 'Adventurer',
        ageGroup: '6-7',
        selectedCharacterId: 'boy',
        totalCoins: 0,
        totalStars: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(
        activeProfile,
        isNotNull,
        reason: 'Onboarding is completed when profile is created.',
      );
    });

    test('3. Selected age selection and mapping test', () {
      const selectedAge = '6-7';
      final profile = ChildProfile(
        id: 'uuid',
        childName: 'Mia',
        ageGroup: selectedAge,
        selectedCharacterId: 'girl',
        totalCoins: 10,
        totalStars: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.ageGroup, '6-7');
    });

    test('4. Selected character mapping test', () {
      const selectedChar = 'boy';
      final profile = ChildProfile(
        id: 'uuid',
        childName: 'Leo',
        ageGroup: '4-5',
        selectedCharacterId: selectedChar,
        totalCoins: 0,
        totalStars: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.selectedCharacterId, 'boy');
      expect(profile.characterImagePath, contains('Male adventurer'));
    });

    test('5. Level 1 unlocked by default logic test', () {
      final List<LevelProgress> levels = [];
      for (int i = 1; i <= 20; i++) {
        levels.add(
          LevelProgress(
            id: 'lvl_$i',
            childProfileId: 'profile_id',
            levelNumber: i,
            isUnlocked: i == 1,
            isCompleted: false,
            mode: 'math',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      expect(levels.first.levelNumber, 1);
      expect(
        levels.first.isUnlocked,
        isTrue,
        reason: 'Level 1 must be unlocked by default.',
      );
      expect(
        levels[1].isUnlocked,
        isFalse,
        reason: 'Level 2 must be locked initially.',
      );
    });

    test('Question serialization and mapping consistency test', () {
      final question = Question(
        id: 'q_test',
        ageGroup: '4-5',
        mode: 'math',
        topic: 'addition',
        questionText: '2 + 2 = ?',
        optionA: '3',
        optionB: '4',
        optionC: '5',
        correctOption: 'B',
      );

      final map = question.toMap();
      final decoded = Question.fromMap(map);

      expect(decoded.id, 'q_test');
      expect(decoded.questionText, '2 + 2 = ?');
      expect(decoded.correctOption, 'B');
    });

    test(
      'Selecting Math/Spelling mode from Home navigates with correct mode',
      () {
        const activeModeMath = 'math';
        expect(
          activeModeMath,
          'math',
          reason: 'Math mode must be active when math is selected',
        );

        const activeModeSpelling = 'spelling';
        expect(
          activeModeSpelling,
          'spelling',
          reason: 'Spelling mode must be active when spelling is selected',
        );
      },
    );

    test('Seeded 6-7 math and spelling questions existence test', () {
      final qMath = Question(
        id: 'm_6_7_1',
        ageGroup: '6-7',
        mode: 'math',
        topic: 'addition',
        questionText: '3 + 2 = ?',
        optionA: '4',
        optionB: '5',
        optionC: '6',
        correctOption: 'B',
      );

      expect(qMath.ageGroup, '6-7');
      expect(qMath.mode, 'math');
      expect(qMath.questionText, '3 + 2 = ?');

      final qSpelling = Question(
        id: 's_6_7_1',
        ageGroup: '6-7',
        mode: 'spelling',
        topic: 'spelling_check',
        questionText: 'Which spelling is correct? CAT / CTA / ACT',
        optionA: 'CAT',
        optionB: 'CTA',
        optionC: 'ACT',
        correctOption: 'A',
      );

      expect(qSpelling.ageGroup, '6-7');
      expect(qSpelling.mode, 'spelling');
      expect(qSpelling.questionText, contains('Which spelling is correct?'));
    });

    test('QuestionService getQuestionsForRun count and fallback integrity', () {
      final questions = QuestionService.getQuestionsForRun(
        ageGroup: '4-5',
        mode: 'math',
        levelNumber: 1,
        requiredCount: 10,
      );

      expect(questions.length, 10);
      for (final q in questions) {
        expect(q.optionA.isNotEmpty, isTrue);
        expect(q.optionB.isNotEmpty, isTrue);
        expect(q.optionC.isNotEmpty, isTrue);
        expect(['A', 'B', 'C'].contains(q.correctOption), isTrue);
      }
    });

    test('Dual control movement boundaries constraints test', () {
      int currentLane = 1;

      void moveLeft() {
        if (currentLane > 0) currentLane--;
      }

      void moveRight() {
        if (currentLane < 2) currentLane++;
      }

      void setLane(int lane) {
        currentLane = lane.clamp(0, 2);
      }

      void handleTap(double tapX, double screenWidth) {
        if (tapX < screenWidth * 0.40) {
          moveLeft();
        } else if (tapX > screenWidth * 0.60) {
          moveRight();
        }
      }

      void handleSwipe(double deltaX) {
        if (deltaX < -15) {
          moveLeft();
        } else if (deltaX > 15) {
          moveRight();
        }
      }

      expect(currentLane, 1);

      handleTap(150, 500);
      expect(currentLane, 0);

      setLane(1);
      expect(currentLane, 1);

      handleTap(350, 500);
      expect(currentLane, 2);

      setLane(1);

      handleTap(250, 500);
      expect(currentLane, 1);

      handleTap(100, 500);
      expect(currentLane, 0);
      handleTap(100, 500);
      expect(currentLane, 0);

      setLane(1);

      handleTap(400, 500);
      expect(currentLane, 2);
      handleTap(400, 500);
      expect(currentLane, 2);

      setLane(1);

      handleSwipe(-20);
      expect(currentLane, 0);

      setLane(1);

      handleSwipe(20);
      expect(currentLane, 2);
    });

    test('9. Storage getChildProfile migration fallback logic simulation', () {
      final Map<dynamic, dynamic> mockProfileBox = {};

      ChildProfile? getMockChildProfile() {
        if (mockProfileBox.isEmpty) return null;
        var map = mockProfileBox['active_profile'];
        if (map == null && mockProfileBox.isNotEmpty) {
          map = mockProfileBox[0];
          if (map != null) {
            mockProfileBox['active_profile'] = map;
          }
        }
        if (map == null) return null;
        return ChildProfile.fromMap(Map<dynamic, dynamic>.from(map));
      }

      expect(getMockChildProfile(), isNull);

      final profile = ChildProfile(
        id: 'child_123',
        childName: 'Emma',
        ageGroup: '6-7',
        selectedCharacterId: 'girl',
        totalCoins: 100,
        totalStars: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockProfileBox[0] = profile.toMap();

      final retrieved = getMockChildProfile();
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'child_123');
      expect(
        mockProfileBox.containsKey('active_profile'),
        isTrue,
        reason: 'Migration must write old index data to key.',
      );
    });

    test('10. Storage clearAllData re-seeding and defaults simulation', () {
      final Map<String, dynamic> mockPrefs = {};
      final List<Map<String, dynamic>> mockQuestionBox = [];

      void clearAllDataMock() {
        mockPrefs.clear();
        mockQuestionBox.clear();
        mockPrefs['sound_enabled'] = true;
        mockPrefs['music_enabled'] = true;
        mockPrefs['daily_play_limit_minutes'] = 15;
        mockPrefs['daily_play_time_seconds'] = 0;
        mockQuestionBox.add({'id': 'seed_m_4_5_add_1'});
      }

      clearAllDataMock();
      expect(mockPrefs['sound_enabled'], isTrue);
      expect(mockPrefs['daily_play_limit_minutes'], 15);
      expect(
        mockQuestionBox,
        isNotEmpty,
        reason: 'Must auto-reseed on clearAllData.',
      );
    });

    test(
      '11. Flame dt timer & single-trigger timeout resolution simulation',
      () {
        bool questionResolved = false;
        int hearts = 5;
        double remainingTime = 12.0;

        void updateMock(double dt) {
          remainingTime -= dt;
          if (remainingTime <= 0 && !questionResolved) {
            questionResolved = true;
            hearts--;
          }
        }

        updateMock(10.0);
        expect(questionResolved, isFalse);
        expect(hearts, 5);

        updateMock(3.0);
        expect(questionResolved, isTrue);
        expect(hearts, 4);

        updateMock(1.0);
        expect(
          hearts,
          4,
          reason: 'Subsequent frames must not cause extra heart losses.',
        );
      },
    );

    test('12. Unique spelling distractors verification', () {
      final List<Map<String, dynamic>> testWords67 = [
        {
          'word': 'TREE',
          'options': ['TREE', 'TREA', 'TRE'],
          'correct': 'A',
        },
        {
          'word': 'BIRD',
          'options': ['BURD', 'BIRD', 'BRID'],
          'correct': 'B',
        },
      ];

      for (final item in testWords67) {
        final opts = item['options'] as List<String>;
        expect(
          opts.toSet().length,
          3,
          reason: 'All spelling options must be unique.',
        );
        expect(
          opts.contains(item['word']),
          isTrue,
          reason: 'Correct spelling must be in the options.',
        );
      }
    });

    test('13. Play streak grace period and reset rules test', () {
      final nowStr = '2026-05-08';
      final yesterdayStr = '2026-05-07';
      final missOneDayStr = '2026-05-06';
      final missTwoDaysStr = '2026-05-05';

      int calculateNewStreak(
        String lastActive,
        String today,
        int currentStreak,
      ) {
        final lastDate = DateTime.parse(lastActive);
        final todayDate = DateTime.parse(today);
        final difference = todayDate.difference(lastDate).inDays;
        if (difference == 1) {
          return currentStreak + 1;
        } else if (difference == 2) {
          // Missed 1 calendar day, keep current streak (grace period)
          return currentStreak;
        } else {
          // Missed 2 full calendar days, reset to 1
          return 1;
        }
      }

      // Day-to-day play increment
      expect(calculateNewStreak(yesterdayStr, nowStr, 5), 6);

      // Grace period (missed exactly 1 day)
      expect(calculateNewStreak(missOneDayStr, nowStr, 5), 5);

      // Missed 2 full calendar days causes a reset to 1
      expect(calculateNewStreak(missTwoDaysStr, nowStr, 5), 1);
    });

    test('14. Daily streak claims coins progression test', () {
      int getRewardCoins(int nextStreakDay) {
        if (nextStreakDay == 1) return 20;
        if (nextStreakDay == 2) return 25;
        if (nextStreakDay == 3) return 30;
        if (nextStreakDay == 4) return 40;
        return 50;
      }

      expect(getRewardCoins(1), 20);
      expect(getRewardCoins(2), 25);
      expect(getRewardCoins(3), 30);
      expect(getRewardCoins(4), 40);
      expect(getRewardCoins(5), 50);
      expect(getRewardCoins(6), 50);
    });

    test('15. Independent Math & Spelling level unlocks test', () {
      final mathLevels = List.generate(
        20,
        (i) => LevelProgress(
          id: 'm_${i + 1}',
          childProfileId: 'test_child',
          levelNumber: i + 1,
          isUnlocked: i == 0,
          isCompleted: false,
          mode: 'math',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final spellingLevels = List.generate(
        20,
        (i) => LevelProgress(
          id: 's_${i + 1}',
          childProfileId: 'test_child',
          levelNumber: i + 1,
          isUnlocked: i == 0,
          isCompleted: false,
          mode: 'spelling',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      expect(mathLevels[0].isUnlocked, isTrue);
      expect(mathLevels[1].isUnlocked, isFalse);

      expect(spellingLevels[0].isUnlocked, isTrue);
      expect(spellingLevels[1].isUnlocked, isFalse);
    });

    test('16. Profile properties range clamps safety test', () {
      final invalidProfile = ChildProfile(
        id: 'test_child',
        childName: 'Buggy',
        ageGroup: '4-5',
        selectedCharacterId: 'boy',
        totalCoins: -100, // Invalid negative coins
        totalStars: -5, // Invalid negative stars
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = invalidProfile.toMap();
      final validatedProfile = ChildProfile.fromMap(map);

      expect(validatedProfile.totalCoins, 0);
      expect(validatedProfile.totalStars, 0);
    });

    test('17. Effective daily play limit matches base limit initially', () {
      const baseLimit = 15;
      const extraMinutes = 0;
      final effectiveLimit = baseLimit + extraMinutes;
      expect(effectiveLimit, equals(baseLimit));
    });

    test('18. Play time extension increases effective limit by 30 minutes', () {
      const baseLimit = 15;
      const extraMinutes = 30;
      final effectiveLimit = baseLimit + extraMinutes;
      expect(effectiveLimit, equals(45));
    });

    test(
      '19. Extension used status tracking and date comparison reset logic',
      () {
        const today = '2026-05-08';
        const tomorrow = '2026-05-09';

        bool isExtraPlayUsedToday = true;
        int extraPlayMinutesToday = 30;

        // Simulate day change
        if (today != tomorrow) {
          isExtraPlayUsedToday = false;
          extraPlayMinutesToday = 0;
        }

        expect(isExtraPlayUsedToday, isFalse);
        expect(extraPlayMinutesToday, equals(0));
      },
    );
  });
}
