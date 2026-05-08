import 'dart:math';
import '../../models/question.dart';
import '../../core/storage/storage_manager.dart';

class QuestionService {
  static final Random _random = Random();

  /// Retrieves exactly [requiredCount] questions for a game run.
  /// Adapts to past accuracy and prioritizes weak topics based on mistake history.
  static List<Question> getQuestionsForRun({
    required String ageGroup,
    required String mode,
    required int levelNumber,
    required int requiredCount,
  }) {
    List<Question> storedQuestions = [];
    try {
      storedQuestions = StorageManager.getQuestionsForAgeGroup(ageGroup, mode);
    } catch (_) {
      storedQuestions = [];
    }

    // 1. Weak Topic Tallying to increase frequency
    String weakTopic = '';
    try {
      final mistakes = StorageManager.getMistakes();
      if (mistakes.isNotEmpty) {
        final tallies = <String, int>{};
        for (final m in mistakes) {
          final t = m.questionText;
          tallies[t] = (tallies[t] ?? 0) + 1;
        }
        final sorted = tallies.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        weakTopic = sorted.first.key;
      }
    } catch (_) {}

    // 2. Adaptive Difficulty Check
    double avgAccuracy = 75.0;
    try {
      final sessions = StorageManager.getGameSessions();
      if (sessions.isNotEmpty) {
        avgAccuracy =
            sessions.map((e) => e.accuracy).reduce((a, b) => a + b) /
            sessions.length;
      }
    } catch (_) {}

    // Sort stored questions to push weak topic or matching difficulty to the front
    storedQuestions.shuffle(_random);
    if (weakTopic.isNotEmpty) {
      storedQuestions.sort((a, b) {
        final hasA = a.questionText.contains(weakTopic) || a.topic == weakTopic;
        final hasB = b.questionText.contains(weakTopic) || b.topic == weakTopic;
        if (hasA && !hasB) return -1;
        if (!hasA && hasB) return 1;
        return 0;
      });
    }

    final List<Question> selected = [];
    final Set<String> usedIds = {};

    for (final q in storedQuestions) {
      if (selected.length >= requiredCount) break;
      if (!usedIds.contains(q.id)) {
        selected.add(q);
        usedIds.add(q.id);
      }
    }

    // 3. Generate dynamic fallback questions with adaptive difficulty and new variety
    int fallbackCount = 1;
    while (selected.length < requiredCount) {
      final id =
          'dyn_fallback_${mode}_${ageGroup}_${levelNumber}_${fallbackCount}_${_random.nextInt(10000)}';
      if (!usedIds.contains(id)) {
        final fallbackQuestion = _generateAdaptiveDynamicFallback(
          id: id,
          ageGroup: ageGroup,
          mode: mode,
          levelNumber: levelNumber,
          avgAccuracy: avgAccuracy,
        );
        selected.add(fallbackQuestion);
        usedIds.add(id);
        fallbackCount++;
      }
    }

    return selected.sublist(0, requiredCount);
  }

  /// Generates a dynamic fallback question with adaptive difficulty and educational formats
  static Question _generateAdaptiveDynamicFallback({
    required String id,
    required String ageGroup,
    required String mode,
    required int levelNumber,
    required double avgAccuracy,
  }) {
    final isHard = avgAccuracy > 85.0;
    final isEasy = avgAccuracy < 50.0;
    final names = ['Emma', 'Leo', 'Mia', 'Noah', 'Ava', 'Max'];
    final name = names[_random.nextInt(names.length)];

    if (mode == 'math') {
      if (ageGroup == '4-5') {
        final roll = _random.nextInt(4);
        if (roll == 0) {
          // --- Emoji Counting ---
          final a = _random.nextInt(3) + 1;
          final b = _random.nextInt(3) + 1;
          final correct = a + b;
          final options = _generateUniqueOptions(correct, minVal: 1);
          final emojisA = '🐶' * a;
          final emojisB = '🐶' * b;

          return Question(
            id: id,
            ageGroup: ageGroup,
            mode: mode,
            topic: 'emoji_counting',
            questionText: '$emojisA + $emojisB = ? How many puppies?',
            optionA: options[0],
            optionB: options[1],
            optionC: options[2],
            correctOption: options[3],
          );
        } else if (roll == 1) {
          // --- Balloon Color matching ---
          final colors = ['🔴 RED', '🔵 BLUE', '🟢 GREEN'];
          final correctIndex = _random.nextInt(3);
          final correctColor = colors[correctIndex];
          final options = List<String>.from(colors)..shuffle(_random);
          final correctLetter = options.indexOf(correctColor) == 0
              ? 'A'
              : (options.indexOf(correctColor) == 1 ? 'B' : 'C');

          return Question(
            id: id,
            ageGroup: ageGroup,
            mode: mode,
            topic: 'color_balloons',
            questionText: '🌈 Pick the ${correctColor.split(' ')[1]} balloon!',
            optionA: options[0],
            optionB: options[1],
            optionC: options[2],
            correctOption: correctLetter,
          );
        } else if (roll == 2) {
          // --- Shapes matching ---
          final shapes = ['🔺 TRIANGLE', '🟩 SQUARE', '🟡 CIRCLE'];
          final correctIndex = _random.nextInt(3);
          final correctShape = shapes[correctIndex];
          final options = List<String>.from(shapes)..shuffle(_random);
          final correctLetter = options.indexOf(correctShape) == 0
              ? 'A'
              : (options.indexOf(correctShape) == 1 ? 'B' : 'C');

          return Question(
            id: id,
            ageGroup: ageGroup,
            mode: mode,
            topic: 'shape_match',
            questionText: 'Which shape is a ${correctShape.split(' ')[1]}?',
            optionA: options[0],
            optionB: options[1],
            optionC: options[2],
            correctOption: correctLetter,
          );
        } else {
          // --- Dino Comparisons ---
          final a = _random.nextInt(4) + 1;
          final b = _random.nextInt(4) + 6;
          final correct = max(a, b);
          final options = _generateUniqueOptions(correct, minVal: 1);

          return Question(
            id: id,
            ageGroup: ageGroup,
            mode: mode,
            topic: 'dino_eat',
            questionText:
                '🦖 Rex the Dino wants to eat the BIGGER number of $a and $b!',
            optionA: options[0],
            optionB: options[1],
            optionC: options[2],
            correctOption: options[3],
          );
        }
      } else if (ageGroup == '6-7') {
        final roll = _random.nextInt(3);
        if (roll == 0) {
          // --- Food Adventure ---
          final a = isEasy ? 2 : (isHard ? 5 : 3);
          final b = isEasy ? 1 : (isHard ? 4 : 2);
          final correct = a + b;
          final options = _generateUniqueOptions(correct, minVal: 1);

          return Question(
            id: id,
            ageGroup: ageGroup,
            mode: mode,
            topic: 'food_adventure',
            questionText:
                '🍎 $name found $a apples. Mia gave him $b more. How many now?',
            optionA: options[0],
            optionB: options[1],
            optionC: options[2],
            correctOption: options[3],
          );
        } else if (roll == 1) {
          // --- Animal story ---
          final sleeping = isEasy ? 3 : (isHard ? 8 : 5);
          final wokeUp = isEasy ? 1 : (isHard ? 4 : 2);
          final correct = sleeping - wokeUp;
          final options = _generateUniqueOptions(correct, minVal: 0);

          return Question(
            id: id,
            ageGroup: ageGroup,
            mode: mode,
            topic: 'animal_adventure',
            questionText:
                '🦁 $sleeping lions were sleeping. $wokeUp woke up. How many still sleep?',
            optionA: options[0],
            optionB: options[1],
            optionC: options[2],
            correctOption: options[3],
          );
        } else {
          // --- Missing Number ---
          final a = isEasy ? 2 : (isHard ? 12 : 6);
          final b = isEasy ? 1 : (isHard ? 8 : 4);
          final correct = a + b;
          final options = _generateUniqueOptions(b, minVal: 1);

          return Question(
            id: id,
            ageGroup: ageGroup,
            mode: mode,
            topic: 'missing_treasure',
            questionText: '💎 Fill the treasure chest: $a + ? = $correct',
            optionA: options[0],
            optionB: options[1],
            optionC: options[2],
            correctOption: options[3],
          );
        }
      } else {
        // --- Age 8-10 (Puzzles, Logic, Rocket Countdown) ---
        final roll = _random.nextInt(3);
        if (roll == 0) {
          // Rocket countdown
          final start = isEasy ? 15 : (isHard ? 40 : 25);
          final step = _random.nextBool() ? 5 : 10;
          final correct = start - 3 * step;
          final options = _generateUniqueOptions(correct, minVal: 0);

          return Question(
            id: id,
            ageGroup: ageGroup,
            mode: mode,
            topic: 'rocket_countdown',
            questionText:
                '🚀 Rocket Countdown! $start, ${start - step}, ${start - 2 * step}, ?',
            optionA: options[0],
            optionB: options[1],
            optionC: options[2],
            correctOption: options[3],
          );
        } else if (roll == 1) {
          // Puzzle chest comparison
          final a = _random.nextInt(30) + 10;
          final b = _random.nextInt(30) + 40;
          final c = _random.nextInt(30) + 70;
          final correct = max(a, max(b, c));
          final options = _generateUniqueOptions(correct, minVal: 1);

          return Question(
            id: id,
            ageGroup: ageGroup,
            mode: mode,
            topic: 'biggest_chest',
            questionText:
                '🏴‍☠️ Which chest holds the BIGGEST number: $a, $b, or $c?',
            optionA: options[0],
            optionB: options[1],
            optionC: options[2],
            correctOption: options[3],
          );
        } else {
          // Advanced logic/multiplication
          final multiplier = isEasy ? 2 : (isHard ? 5 : 3);
          final count = _random.nextInt(4) + 2;
          final correct = count * multiplier;
          final options = _generateUniqueOptions(correct, minVal: 1);

          return Question(
            id: id,
            ageGroup: ageGroup,
            mode: mode,
            topic: 'magic_factory',
            questionText:
                '🤖 Each robot holds $multiplier gears. How many do $count robots hold?',
            optionA: options[0],
            optionB: options[1],
            optionC: options[2],
            correctOption: options[3],
          );
        }
      }
    } else {
      // Spelling modes with interactive prompts
      if (ageGroup == '4-5') {
        final pair = _random.nextBool()
            ? ['CAT 🐱', 'C']
            : (_random.nextBool() ? ['DOG 🐶', 'D'] : ['SUN ☀️', 'S']);
        final options = _generateUniqueSpellingOptions(pair[1], [
          'A',
          'B',
          'M',
          'P',
          'R',
          'T',
        ]);

        return Question(
          id: id,
          ageGroup: ageGroup,
          mode: mode,
          topic: 'frog_spelling',
          questionText:
              '🐸 Help the frog jump to the first letter of "${pair[0]}"!',
          optionA: options[0],
          optionB: options[1],
          optionC: options[2],
          correctOption: options[3],
        );
      } else {
        final wordList = isEasy
            ? ['BUS', 'PEN', 'HAT', 'BOX']
            : (isHard
                  ? ['ELEPHANT', 'WONDERFUL', 'PLAYGROUND']
                  : ['TREE', 'BIRD', 'FROG', 'MOON']);
        final word = wordList[_random.nextInt(wordList.length)];
        final wrong1 =
            word
                .replaceAll('EE', 'EA')
                .replaceAll('O', 'OO')
                .replaceAll('A', 'AY') +
            (word.endsWith('S') ? '' : 'S');
        final wrong2 = word.split('').reversed.join();
        final options = _shuffleSpellingOptions(
          word,
          wrong1 != word ? wrong1 : '${word}Y',
          wrong2 != word ? wrong2 : 'X$word',
        );

        return Question(
          id: id,
          ageGroup: ageGroup,
          mode: mode,
          topic: 'adventure_spelling',
          questionText: '✨ Find the perfect spelling of this word!',
          optionA: options[0],
          optionB: options[1],
          optionC: options[2],
          correctOption: options[3],
        );
      }
    }
  }

  static List<String> _generateUniqueOptions(int correct, {int minVal = 0}) {
    final Set<int> optionVals = {correct};
    while (optionVals.length < 3) {
      final offset = _random.nextInt(5) + 1;
      final val = _random.nextBool() ? correct + offset : correct - offset;
      if (val >= minVal) {
        optionVals.add(val);
      }
    }

    final List<int> sortedOptions = optionVals.toList()..shuffle(_random);
    final optA = sortedOptions[0].toString();
    final optB = sortedOptions[1].toString();
    final optC = sortedOptions[2].toString();

    final correctIndex = sortedOptions.indexOf(correct);
    final correctLetter = correctIndex == 0
        ? 'A'
        : (correctIndex == 1 ? 'B' : 'C');

    return [optA, optB, optC, correctLetter];
  }

  static List<String> _generateUniqueSpellingOptions(
    String correct,
    List<String> pool,
  ) {
    final Set<String> optionVals = {correct};
    while (optionVals.length < 3) {
      optionVals.add(pool[_random.nextInt(pool.length)]);
    }

    final List<String> sortedOptions = optionVals.toList()..shuffle(_random);
    final optA = sortedOptions[0];
    final optB = sortedOptions[1];
    final optC = sortedOptions[2];

    final correctIndex = sortedOptions.indexOf(correct);
    final correctLetter = correctIndex == 0
        ? 'A'
        : (correctIndex == 1 ? 'B' : 'C');

    return [optA, optB, optC, correctLetter];
  }

  static List<String> _shuffleSpellingOptions(
    String correct,
    String wrong1,
    String wrong2,
  ) {
    final List<String> options = [correct, wrong1, wrong2]..shuffle(_random);
    final optA = options[0];
    final optB = options[1];
    final optC = options[2];

    final correctIndex = options.indexOf(correct);
    final correctLetter = correctIndex == 0
        ? 'A'
        : (correctIndex == 1 ? 'B' : 'C');

    return [optA, optB, optC, correctLetter];
  }
}
