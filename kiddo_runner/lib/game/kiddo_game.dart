import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';
import 'dart:math';
import '../core/storage/storage_manager.dart';
import '../core/storage/music_manager.dart';
import '../models/question.dart';
import '../models/theme_reward.dart';
import '../core/constants/theme_rewards.dart';
import '../screens/result_screen.dart';
import '../screens/level_map_screen.dart';
import 'services/question_service.dart';

class FloatingPraise {
  final String text;
  double x;
  double y;
  double duration;
  final Color color;
  FloatingPraise(this.text, this.x, this.y, this.duration, this.color);
}

class GameParticle {
  double x;
  double y;
  double vx;
  double vy;
  final Color color;
  double size;
  double life;
  final bool isStar;
  GameParticle(
    this.x,
    this.y,
    this.vx,
    this.vy,
    this.color,
    this.size,
    this.life, {
    this.isStar = false,
  });
}

class KiddoGame extends FlameGame with PanDetector, TapCallbacks {
  int combo = 0;
  final List<GameParticle> _particles = [];
  final List<FloatingPraise> _floatingPraises = [];
  double _wrongCloudTimer = 0.0;
  String _activeSpeechBubble = '';
  double _speechBubbleTimer = 0.0;
  double _petStateTimer = 0.0;
  String _petReaction = 'idle';
  double _shieldTimer = 0.0;

  KiddoGame({
    required this.levelNumber,
    required this.mode,
    required this.context,
  });

  final int levelNumber;
  final String mode;
  final BuildContext context;

  int hearts = 5;
  int coins = 0;
  int currentQuestionIndex = 0;
  List<Question> questionBank = [];
  bool isGameOver = false;

  Question? currentQuestion;
  double activeTimer = 1.0;
  double remainingQuestionTime = 12.0;

  int currentLane = 1;
  double characterX = 0;
  double targetX = 0;

  double objectY = -100;
  double objectSpeed = 250;

  final List<Map<String, String>> mistakes = [];
  late Sprite characterSprite;
  bool useProceduralCharacter = false;
  bool _questionResolved = false;

  // Session Flow States
  double _countdownTimer = 3.0; // pre-run countdown
  bool isPaused = false;

  Sprite? hatSprite;

  // Trail state
  final List<Offset> _trailPositions = [];
  final Paint _trailPaint = Paint()..style = PaintingStyle.fill;
  String activeHat = 'none';
  String activeTrail = 'none';
  String activeTheme = 'blue';

  // Visual polish timers
  double _runTimer = 0.0;
  double _correctFeedbackTimer = 0.0;
  double _wrongFeedbackTimer = 0.0;

  // Optimized class-level fields to reduce garbage collection allocations
  final Paint _rectPaint = Paint()..color = Colors.white;
  final Paint _borderPaint = Paint()
    ..color = const Color(0xFF0EA5E9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final Paint _bgTimerPaint = Paint()..color = const Color(0xFFE2E8F0);
  final Paint _bodyPaint = Paint();
  final Paint _eyePaint = Paint()..color = Colors.white;
  final Paint _pupilPaint = Paint()..color = Colors.black;
  final Paint _hatPaint = Paint();


  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  // ── Mode helper ────────────────────────────────────────────────────────────
  bool get isSpellingMode {
    final n = mode.toLowerCase().trim();
    return n == 'spelling' ||
        n == 'spelling_adventure' ||
        n == 'word' ||
        n == 'words' ||
        n.contains('spell');
  }

  // Character Animation
  List<Sprite> runSprites = [];
  Sprite? jumpSprite;
  Sprite? hurtSprite;
  Sprite? idleSprite;
  double _animTimer = 0;
  int _animFrame = 0;

  bool isJumping = false;
  double jumpVelocity = 0;
  double characterYOffset = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    debugPrint('KiddoGame mode: $mode  |  isSpellingMode: $isSpellingMode');

    MusicManager.playGameMusic();

    // Fetch equipped cosmetics
    activeHat = StorageManager.equippedHat;
    activeTrail = StorageManager.equippedTrail;
    activeTheme = StorageManager.equippedTheme;
    debugPrint(
      'KiddoGame Cosmetics: Hat=$activeHat, Trail=$activeTrail, Theme=$activeTheme',
    );

    final profile = StorageManager.getChildProfile();
    final characterId = profile?.selectedCharacterId ?? 'boy';

    String baseFolder = 'Male adventurer';
    String filePrefix = 'character_maleAdventurer';

    if (characterId == 'girl') {
      baseFolder = 'Female adventurer';
      filePrefix = 'character_femaleAdventurer';
    } else if (characterId == 'ninja_outfit') {
      baseFolder = 'Male person';
      filePrefix = 'character_malePerson';
    } else if (characterId == 'super_star') {
      baseFolder = 'Robot';
      filePrefix = 'character_robot';
    } else if (characterId == 'zombie') {
      baseFolder = 'Zombie';
      filePrefix = 'character_zombie';
    } else if (characterId == 'female_person') {
      baseFolder = 'Female person';
      filePrefix = 'character_femalePerson';
    }

    final basePath =
        'characters/kenney_toon-characters/$baseFolder/PNG/Poses HD/';

    // Load Hat Sprite if equipped
    if (activeHat != 'none') {
      try {
        hatSprite = await loadSprite('reward/$activeHat.png');
      } catch (e) {
        debugPrint('Could not load primary hat sprite: $e. Using fallback.');
        try {
          hatSprite = await loadSprite('reward/dummy_reward.png');
        } catch (e2) {
          debugPrint('Could not load fallback hat sprite: $e2');
        }
      }
    }

    try {
      // Load Idle
      idleSprite = Sprite(
        await images.load('${basePath}${filePrefix}_idle.png'),
      );
      characterSprite = idleSprite!;

      // Load Run
      runSprites = [
        Sprite(await images.load('${basePath}${filePrefix}_run0.png')),
        Sprite(await images.load('${basePath}${filePrefix}_run1.png')),
        Sprite(await images.load('${basePath}${filePrefix}_run2.png')),
      ];

      // Load Jump
      jumpSprite = Sprite(
        await images.load('${basePath}${filePrefix}_jump.png'),
      );

      // Load Hurt
      hurtSprite = Sprite(
        await images.load('${basePath}${filePrefix}_hurt.png'),
      );
    } catch (e) {
      debugPrint('Error loading sprites: $e');
      useProceduralCharacter = true;
    }

    final ageGroup = profile?.ageGroup ?? '4-5';
    questionBank = QuestionService.getQuestionsForRun(
      ageGroup: ageGroup,
      mode: mode,
      levelNumber: levelNumber,
      requiredCount: 10,
    );

    _loadNextQuestion();

    characterX = size.x / 2;
    targetX = characterX;
    _activeSpeechBubble = "Let's run, friend! 🏃‍♂️💨";
    _speechBubbleTimer = 2.5;
  }

  void _loadNextQuestion() {
    _questionResolved = false;
    if (currentQuestionIndex >= questionBank.length) {
      _endGame(win: true);
      return;
    }

    currentQuestion = questionBank[currentQuestionIndex];
    objectY = -120;
    remainingQuestionTime = 12.0;
    activeTimer = 1.0;
  }

  void moveLeft() {
    if (currentLane > 0) {
      currentLane--;
    }
  }

  void moveRight() {
    if (currentLane < 2) {
      currentLane++;
    }
  }

  void setLane(int lane) {
    currentLane = lane.clamp(0, 2);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tapX = event.localPosition.x;
    final tapY = event.localPosition.y;

    // 1. Check if Pause button icon is tapped (rendered near size.x - 45, 135)
    if (tapX > size.x - 65 && tapY > 110 && tapY < 180) {
      isPaused = !isPaused;
      return;
    }

    // If game is currently paused, verify if Resume or Quit Run button is tapped
    if (isPaused) {
      final rectResume = Rect.fromLTWH(
        size.x / 2 - 100,
        size.y / 2 - 50,
        200,
        50,
      );
      final rectQuit = Rect.fromLTWH(
        size.x / 2 - 100,
        size.y / 2 + 20,
        200,
        50,
      );

      if (rectResume.contains(Offset(tapX, tapY))) {
        isPaused = false;
        return;
      }

      if (rectQuit.contains(Offset(tapX, tapY))) {
        isPaused = false;
        MusicManager.playMenuMusic();
        final activeContext = buildContext;
        if (activeContext != null && activeContext.mounted) {
          Navigator.of(activeContext).pushReplacement(
            MaterialPageRoute(builder: (_) => LevelMapScreen(mode: mode)),
          );
        }
        return;
      }
      return; // Swallow other taps while paused
    }

    if (isGameOver || _countdownTimer > 0) return;

    final screenWidth = size.x;
    if (tapX < screenWidth / 3) {
      setLane(0);
    } else if (tapX < (screenWidth / 3) * 2) {
      setLane(1);
    } else {
      setLane(2);
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver || isPaused || _countdownTimer > 0) return;

    final deltaX = info.delta.global.x;
    if (deltaX < -15) {
      moveLeft();
    } else if (deltaX > 15) {
      moveRight();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (currentQuestion == null && !isGameOver) return; // Guard against race conditions during load
    if (isGameOver || isPaused) return;

    // Handle Pre-run Countdown timer
    if (_countdownTimer > 0) {
      _countdownTimer -= dt;
      return;
    }

    _runTimer += dt * 12;

    if (_correctFeedbackTimer > 0) {
      _correctFeedbackTimer -= dt;
    }
    if (_wrongFeedbackTimer > 0) {
      _wrongFeedbackTimer -= dt;
    }
    if (_wrongCloudTimer > 0) {
      _wrongCloudTimer -= dt;
    }
    if (_speechBubbleTimer > 0) {
      _speechBubbleTimer -= dt;
    }
    if (_shieldTimer > 0) {
      _shieldTimer -= dt;
    }
    if (_petStateTimer > 0) {
      _petStateTimer -= dt;
    }

    // Dynamic Speed adaptation
    objectSpeed = (250 + (combo * 15)).toDouble().clamp(200.0, 400.0);

    // Particle Physics
    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 250 * dt; // gravity
      p.life -= dt;
      if (p.life <= 0) {
        _particles.removeAt(i);
      }
    }

    // Floating Praises physics
    for (int i = _floatingPraises.length - 1; i >= 0; i--) {
      final fp = _floatingPraises[i];
      fp.y -= 80 * dt;
      fp.duration -= dt;
      if (fp.duration <= 0) {
        _floatingPraises.removeAt(i);
      }
    }

    // Maintain trail positions
    _trailPositions.add(Offset(characterX, size.y - 150));
    if (_trailPositions.length > 8) {
      _trailPositions.removeAt(0);
    }

    final double laneWidth = size.x / 3;
    targetX = (currentLane * laneWidth) + (laneWidth / 2);
    characterX += (targetX - characterX) * 15 * dt;

    objectY += objectSpeed * dt;

    remainingQuestionTime -= dt;
    if (remainingQuestionTime < 0) remainingQuestionTime = 0;
    activeTimer = (remainingQuestionTime / 12.0).clamp(0.0, 1.0);

    if (remainingQuestionTime <= 0 && !_questionResolved) {
      _questionResolved = true;
      _wrongFeedbackTimer = 0.5;
      _wrongCloudTimer = 1.5;
      combo = 0;
      _handleWrongAnswer(selected: 'TIMEOUT');
      currentQuestionIndex++;
      _loadNextQuestion();
    }

    if (objectY >= size.y - 220 && !_questionResolved) {
      _checkCollision();
    }

    // --- Character Animation & Physics ---
    if (isJumping) {
      characterYOffset += jumpVelocity * dt;
      jumpVelocity += 1200 * dt; // Gravity
      if (characterYOffset >= 0) {
        characterYOffset = 0;
        isJumping = false;
        jumpVelocity = 0;
      }
    }

    if (!useProceduralCharacter) {
      if (_wrongFeedbackTimer > 0) {
        characterSprite = hurtSprite ?? idleSprite!;
      } else if (isJumping) {
        characterSprite = jumpSprite ?? idleSprite!;
      } else if (!isGameOver && _countdownTimer <= 0) {
        _animTimer += dt;
        if (_animTimer > 0.1) {
          _animTimer = 0;
          _animFrame = (_animFrame + 1) % runSprites.length;
          if (runSprites.isNotEmpty) {
            characterSprite = runSprites[_animFrame];
          }
        }
      } else {
        if (idleSprite != null) {
          characterSprite = idleSprite!;
        }
      }
    }
  }

  void _spawnConfetti(double px, double py) {
    final random = Random();
    for (int i = 0; i < 25; i++) {
      final angle = random.nextDouble() * pi * 2;
      final speed = random.nextDouble() * 180 + 80;
      final Color color =
          Colors.primaries[random.nextInt(Colors.primaries.length)];
      _particles.add(
        GameParticle(
          px,
          py,
          cos(angle) * speed,
          sin(angle) * speed,
          color,
          random.nextDouble() * 8 + 4,
          0.6 + random.nextDouble() * 0.4,
          isStar: random.nextBool(),
        ),
      );
    }
  }

  void _checkCollision() {
    if (currentQuestion == null || _questionResolved) return;
    _questionResolved = true;

    final String selectedOption = currentLane == 0
        ? 'A'
        : (currentLane == 1 ? 'B' : 'C');
    final bool isCorrect = selectedOption == currentQuestion!.correctOption;

    if (isCorrect) {
      combo++;
      coins += 5;
      _correctFeedbackTimer = 0.5;
      MusicManager.playSfx('correct.wav');

      // Victory Jump!
      isJumping = true;
      jumpVelocity = -500;

      // Spawn stars and confetti particles!
      _spawnConfetti(characterX, size.y - 150);

      // Add a floating praise text!
      final praises = [
        'AWESOME! 🎉',
        'WOW! 🌟',
        'GREAT JOB! 👍',
        'PERFECT! 💯',
        'AMAZING! ✨',
      ];
      final praise = praises[Random().nextInt(praises.length)];
      final praiseColor =
          Colors.primaries[Random().nextInt(Colors.primaries.length)];
      _floatingPraises.add(
        FloatingPraise(praise, characterX, size.y - 180, 1.2, praiseColor),
      );

      // Combo special titles
      if (combo == 5) {
        _floatingPraises.add(
          FloatingPraise(
            'SUPER SMART! 🌟',
            size.x / 2,
            size.y / 2 - 50,
            1.8,
            Colors.amber,
          ),
        );
        _activeSpeechBubble = "Wow, 5 correct in a row! 🚀";
        _speechBubbleTimer = 2.0;
        _petReaction = 'happy';
        _petStateTimer = 1.5;
      } else if (combo == 10) {
        _floatingPraises.add(
          FloatingPraise(
            'GENIUS RUN! 🚀',
            size.x / 2,
            size.y / 2 - 50,
            2.0,
            Colors.pink,
          ),
        );
        _activeSpeechBubble = "You are a GENIUS! 🧠✨";
        _speechBubbleTimer = 2.5;
        _petReaction = 'happy';
        _petStateTimer = 2.0;
      } else {
        final petEncouragements = [
          'Yay! Correct! 💖',
          'Super fast! ⚡',
          'Keep it up! ⭐',
          'Amazing! 🪙',
        ];
        _activeSpeechBubble =
            petEncouragements[Random().nextInt(petEncouragements.length)];
        _speechBubbleTimer = 1.8;
        _petReaction = 'happy';
        _petStateTimer = 1.0;
      }
    } else {
      _wrongFeedbackTimer = 0.5;
      _wrongCloudTimer = 1.5;
      combo = 0;
      _handleWrongAnswer(selected: selectedOption);
    }

    currentQuestionIndex++;
    _loadNextQuestion();
  }

  void _handleWrongAnswer({required String selected}) {
    if (currentQuestion == null) return;

    // 30% chance of a Near-Miss shield save!
    final isNearMissSave = Random().nextDouble() < 0.3;
    if (isNearMissSave) {
      _shieldTimer = 1.5;
      _activeSpeechBubble = "TRY AGAIN HERO! ❤️🛡️";
      _speechBubbleTimer = 2.0;
      MusicManager.playSfx('correct.wav');
      _floatingPraises.add(
        FloatingPraise(
          'SHIELD SAVE! 🛡️',
          characterX,
          size.y - 180,
          1.5,
          Colors.blue,
        ),
      );
    } else {
      hearts--;
      if (hearts < 0) hearts = 0;
      _activeSpeechBubble = "Almost there! You've got this! ✨";
      _speechBubbleTimer = 2.0;
      _petReaction = 'sad';
      _petStateTimer = 1.5;
      MusicManager.playSfx('wrong.wav');
    }

    final qText = currentQuestion!.questionText;
    final selectedVal = selected == 'A'
        ? currentQuestion!.optionA
        : (selected == 'B'
              ? currentQuestion!.optionB
              : (selected == 'C' ? currentQuestion!.optionC : 'TIMEOUT'));
    final correctVal = currentQuestion!.correctOption == 'A'
        ? currentQuestion!.optionA
        : (currentQuestion!.correctOption == 'B'
              ? currentQuestion!.optionB
              : currentQuestion!.optionC);

    mistakes.add({
      'question': qText,
      'selected': selectedVal,
      'correct': correctVal,
    });

    if (hearts <= 0) {
      _endGame(win: false);
    }
  }

  void _endGame({required bool win}) {
    if (isGameOver) return;
    isGameOver = true;

    MusicManager.playMenuMusic();
    if (win) {
      MusicManager.playSfx('level_complete.wav');
    }

    final totalQuestions = questionBank.isNotEmpty ? questionBank.length : 1;
    final double accuracy =
        ((totalQuestions - mistakes.length) / totalQuestions) * 100;
    final stars = win ? (accuracy >= 80 ? 3 : (accuracy >= 50 ? 2 : 1)) : 0;

    // Safety check for Navigator context
    final activeContext = buildContext ?? context;
    if (activeContext.mounted) {
      Navigator.of(activeContext).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            levelNumber: levelNumber,
            mode: mode,
            score: coins * 10,
            stars: stars,
            accuracy: accuracy.clamp(0.0, 100.0),
            coins: coins,
            mistakes: mistakes,
          ),
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas); // Always call this first

    if (currentQuestion == null && !isGameOver) return; // Guard after super

    final theme = ThemeRewards.getTheme(activeTheme);
    Color baseBg = theme.backgroundColor;
    Color roadColor = theme.laneColor;
    String worldTitle = '${theme.name} ${theme.iconEmoji}';

    // Special animation for rainbow theme
    if (activeTheme == 'rainbow') {
      final double cycle = (DateTime.now().millisecondsSinceEpoch % 3000) / 3000;
      baseBg = HSVColor.fromAHSV(1.0, cycle * 360, 0.05, 0.98).toColor();
      roadColor = HSVColor.fromAHSV(1.0, cycle * 360, 0.1, 0.95).toColor();
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = baseBg,
    );

    final double laneWidth = size.x / 3;

    // Draw faint lane backgrounds
    final laneBgA = Paint()
      ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.25);
    final laneBgB = Paint()
      ..color = const Color(0xFFFEF9C3).withValues(alpha: 0.25);
    final laneBgC = Paint()
      ..color = const Color(0xFFF3E8FF).withValues(alpha: 0.25);
    canvas.drawRect(Rect.fromLTWH(0, 0, laneWidth, size.y), laneBgA);
    canvas.drawRect(Rect.fromLTWH(laneWidth, 0, laneWidth, size.y), laneBgB);
    canvas.drawRect(
      Rect.fromLTWH(laneWidth * 2, 0, laneWidth, size.y),
      laneBgC,
    );

    // UI Improvement 1: Dashed lane divider lines
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.y; y += 35) {
      canvas.drawRect(Rect.fromLTWH(laneWidth - 2, y, 4, 20), dashPaint);
      canvas.drawRect(Rect.fromLTWH(laneWidth * 2 - 2, y, 4, 20), dashPaint);
    }

    // Draw active World Title
    _textPainter.text = TextSpan(
      text: worldTitle,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: levelNumber > 3 && levelNumber <= 7
            ? Colors.white38
            : Colors.black38,
      ),
    );
    _textPainter.layout();
    _textPainter.paint(canvas, const Offset(20, 15));

    if (isGameOver || currentQuestion == null) return;

    // --- Draw Custom Cosmetic Trail ---
    if (activeTrail != 'none') {
      for (int i = 0; i < _trailPositions.length; i++) {
        final pos = _trailPositions[i];
        final opacity = (i + 1) / _trailPositions.length * 0.7;
        if (activeTrail == 'rainbow_trail') {
          final colors = [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.purple,
          ];
          _trailPaint.color = colors[i % colors.length].withValues(
            alpha: opacity,
          );
        } else if (activeTrail == 'star_trail') {
          _trailPaint.color = Colors.amber.withValues(alpha: opacity);
        } else {
          _trailPaint.color = Colors.deepOrange.withValues(alpha: opacity);
        }
        canvas.drawCircle(pos, 16, _trailPaint);
      }
    }

    // Apply Screen Shake if wrong response / timeout
    canvas.save();
    if (_wrongFeedbackTimer > 0) {
      final shakeX = sin(_wrongFeedbackTimer * 50) * 8;
      final shakeY = cos(_wrongFeedbackTimer * 50) * 8;
      canvas.translate(shakeX, shakeY);
    }

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 40, size.x - 40, 70),
      const Radius.circular(16),
    );
    // UI Improvement 1: Warm cream question box
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFFFF9E6));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFFF9800)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    _textPainter.text = TextSpan(
      text: currentQuestion!.questionText,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
      ),
    );
    _textPainter.layout(maxWidth: size.x - 80);
    _textPainter.paint(canvas, const Offset(40, 60));

    // Rounded color-transition progress bar (green -> yellow -> red)
    Color timerColor;
    if (activeTimer > 0.5) {
      timerColor = Color.lerp(
        Colors.orange,
        Colors.green,
        (activeTimer - 0.5) * 2,
      )!;
    } else {
      timerColor = Color.lerp(Colors.red, Colors.orange, activeTimer * 2)!;
    }

    final timerBarRectBg = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 115, size.x - 40, 12),
      const Radius.circular(6),
    );
    canvas.drawRRect(timerBarRectBg, _bgTimerPaint);

    // UI Improvement 1: Timer bar clock emoji
    _textPainter.text = const TextSpan(
      text: '⏱️',
      style: TextStyle(fontSize: 14),
    );
    _textPainter.layout();
    _textPainter.paint(canvas, Offset(size.x - 35, 112));

    if (activeTimer > 0) {
      final timerPaint = Paint()..color = timerColor;
      final timerBarRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 115, (size.x - 40) * activeTimer, 12),
        const Radius.circular(6),
      );
      canvas.drawRRect(timerBarRect, timerPaint);
    }

    // Hearts indicator with pulsation
    final isLowHearts = hearts <= 2;
    final double heartScale = isLowHearts
        ? (1.0 + 0.15 * sin(_runTimer * 1.5))
        : 1.0;

    // UI Improvement 1: Soft pink glow behind hearts
    final heartsGlowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(14, 128, hearts * 34.0 + 8.0, 38),
      const Radius.circular(10),
    );
    canvas.drawRRect(heartsGlowRect, Paint()..color = const Color(0xFFFFE4E6));

    canvas.save();
    canvas.translate(20, 135);
    canvas.scale(heartScale);
    _textPainter.text = TextSpan(
      text: '❤️ ' * hearts,
      style: const TextStyle(fontSize: 22),
    );
    _textPainter.layout();
    _textPainter.paint(canvas, const Offset(0, 0));
    canvas.restore();

    // UI Improvement 1: Gold pill behind coins
    _textPainter.text = TextSpan(
      text: '🪙 $coins',
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFFDE911D),
      ),
    );
    _textPainter.layout();
    final coinsRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.x - 140 - 8,
        135 - 2,
        _textPainter.width + 16,
        _textPainter.height + 4,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(coinsRect, Paint()..color = const Color(0xFFFFF3C7));
    _textPainter.paint(canvas, Offset(size.x - 140, 135));

    if (combo >= 2) {
      _textPainter.text = TextSpan(
        text: '🔥 Combo x$combo',
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF6B00),
        ),
      );
      _textPainter.layout();
      final comboRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x - 140 - 8,
          160 - 2,
          _textPainter.width + 16,
          _textPainter.height + 4,
        ),
        const Radius.circular(10),
      );
      canvas.drawRRect(comboRect, Paint()..color = const Color(0xFFFFEDD5));
      _textPainter.paint(canvas, Offset(size.x - 140, 160));
    }

    // Render Pause button indicator (top right corner, top-right area)
    _textPainter.text = TextSpan(
      text: isPaused ? '▶️' : '⏸️',
      style: const TextStyle(fontSize: 24),
    );
    _textPainter.layout();
    _textPainter.paint(canvas, Offset(size.x - 45, 135));

    // ── HORIZONTAL ANSWER OPTIONS ──
    _drawHorizontalGate(canvas, 0, currentQuestion!.optionA, laneWidth);
    _drawHorizontalGate(canvas, 1, currentQuestion!.optionB, laneWidth);
    _drawHorizontalGate(canvas, 2, currentQuestion!.optionC, laneWidth);

    // Easing running squash and stretch
    final isMoving = (targetX - characterX).abs() > 5.0;
    final double scaleX = isMoving ? 1.15 : (1.0 + 0.05 * sin(_runTimer));
    final double scaleY = isMoving ? 0.85 : (1.0 - 0.05 * sin(_runTimer));

    // Apply color theme to the procedural/overlay parts
    Color themeColor = const Color(0xFF0284C7);
    if (activeTheme == 'pink') {
      themeColor = Colors.pink;
    } else if (activeTheme == 'green') {
      themeColor = Colors.green;
    } else if (activeTheme == 'gold') {
      themeColor = Colors.amber;
    }

    _bodyPaint.color = themeColor;

    if (useProceduralCharacter) {
      canvas.save();
      canvas.translate(characterX, size.y - 150 + characterYOffset);
      canvas.scale(scaleX, scaleY);
      canvas.drawCircle(const Offset(0, 0), 30, _bodyPaint);
      canvas.drawCircle(const Offset(-10, -5), 6, _eyePaint);
      canvas.drawCircle(const Offset(10, -5), 6, _eyePaint);
      canvas.drawCircle(const Offset(-10, -5), 3, _pupilPaint);
      canvas.drawCircle(const Offset(10, -5), 3, _pupilPaint);

      // Draw custom equipped hat on the procedural character
      _drawHatOverlay(canvas, 0, -25);

      canvas.restore();
    } else {
      // --- THEME GLOW EFFECT ---
      if (activeTheme != 'blue') {
        final glowPaint = Paint()
          ..color = themeColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
        canvas.drawCircle(
          Offset(characterX, size.y - 150 + characterYOffset),
          45,
          glowPaint,
        );
      }

      final sizeX = 80.0 * scaleX;
      final sizeY = 80.0 * scaleY;
      characterSprite.render(
        canvas,
        position: Vector2(
          characterX - sizeX / 2,
          size.y - 150 - sizeY / 2 + characterYOffset,
        ),
        size: Vector2(sizeX, sizeY),
      );

      // Draw custom equipped hat on top of the sprite
      _drawHatOverlay(
        canvas,
        characterX,
        size.y - 150 - sizeY / 2 + characterYOffset,
      );
    }

    // --- Draw Pet Buddy Following Character ---
    String petEmoji = '🐉';
    if (levelNumber <= 3) {
      petEmoji = '🐉';
    } else if (levelNumber <= 7) {
      petEmoji = '🤖';
    } else if (levelNumber <= 11) {
      petEmoji = '🦄';
    } else if (levelNumber <= 15) {
      petEmoji = '🐒';
    } else {
      petEmoji = '🦖';
    }

    if (_petReaction == 'happy' && _petStateTimer > 0) {
      petEmoji = '$petEmoji ✨';
    } else if (_petReaction == 'sad' && _petStateTimer > 0) {
      petEmoji = '$petEmoji 😢';
    }
    final petX = characterX - 55;
    final petY = size.y - 165 + sin(_runTimer * 0.5) * 8;
    _textPainter.text = TextSpan(
      text: petEmoji,
      style: const TextStyle(fontSize: 28),
    );
    _textPainter.layout();
    _textPainter.paint(
      canvas,
      Offset(petX - _textPainter.width / 2, petY - _textPainter.height / 2),
    );

    // --- Draw Shield Save Overlay ---
    if (_shieldTimer > 0) {
      final shieldPaint = Paint()
        ..color = Colors.blue.withValues(
          alpha: (_shieldTimer / 1.5).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      canvas.drawCircle(Offset(characterX, size.y - 150), 45, shieldPaint);
    }

    // --- Draw Sleepy Failure Cloud ---
    if (_wrongCloudTimer > 0) {
      _textPainter.text = const TextSpan(
        text: '☁️😴 Oops!',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      );
      _textPainter.layout();
      _textPainter.paint(
        canvas,
        Offset(characterX - _textPainter.width / 2, size.y - 215),
      );
    }

    // --- Draw Encouraging Speech Bubble ---
    if (_speechBubbleTimer > 0 && _activeSpeechBubble.isNotEmpty) {
      final bubbleX = characterX;
      final bubbleY = size.y - 235;
      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bubbleX - 85, bubbleY - 35, 170, 40),
        const Radius.circular(12),
      );
      canvas.drawRRect(bubbleRect, Paint()..color = Colors.white);
      canvas.drawRRect(
        bubbleRect,
        Paint()
          ..color = Colors.orangeAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      _textPainter.text = TextSpan(
        text: _activeSpeechBubble,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
      _textPainter.layout(maxWidth: 160);
      _textPainter.paint(
        canvas,
        Offset(
          bubbleX - _textPainter.width / 2,
          bubbleY - 15 - _textPainter.height / 2,
        ),
      );
    }

    // --- Draw Confetti & Star Particles ---
    for (final p in _particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: (p.life / 1.0).clamp(0.0, 1.0));
      if (p.isStar) {
        final path = Path()
          ..moveTo(p.x, p.y - p.size)
          ..lineTo(p.x + p.size * 0.5, p.y + p.size * 0.5)
          ..lineTo(p.x - p.size * 0.5, p.y + p.size * 0.5)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
      }
    }

    // --- Draw Floating Praise Texts ---
    for (final fp in _floatingPraises) {
      _textPainter.text = TextSpan(
        text: fp.text,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: fp.color.withValues(
            alpha: (fp.duration / 1.2).clamp(0.0, 1.0),
          ),
        ),
      );
      _textPainter.layout();
      _textPainter.paint(canvas, Offset(fp.x - _textPainter.width / 2, fp.y));
    }

    canvas.restore(); // Restore screen shake canvas.save

    // Pre-run Countdown Overlay
    if (_countdownTimer > 0) {
      final countdownText = _countdownTimer > 1.0
          ? _countdownTimer.ceil().toString()
          : 'RUN!';
      _textPainter.text = TextSpan(
        text: countdownText,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: countdownText == 'RUN!' ? Colors.green : Colors.orange,
        ),
      );
      _textPainter.layout();
      _textPainter.paint(
        canvas,
        Offset(
          size.x / 2 - _textPainter.width / 2,
          size.y * 0.45 - _textPainter.height / 2,
        ),
      );
    }

    // Pause Overlay
    if (isPaused) {
      final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), overlayPaint);

      // GAME PAUSED header
      _textPainter.text = const TextSpan(
        text: 'GAME PAUSED ⏸️',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      _textPainter.layout();
      _textPainter.paint(
        canvas,
        Offset(
          size.x / 2 - _textPainter.width / 2,
          size.y / 2 - 140 - _textPainter.height / 2,
        ),
      );

      // Resume Button Background
      final resumeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x / 2 - 100, size.y / 2 - 50, 200, 50),
        const Radius.circular(25),
      );
      final resumePaint = Paint()..color = Colors.green;
      canvas.drawRRect(resumeRect, resumePaint);

      // Resume Button Text
      _textPainter.text = const TextSpan(
        text: 'RESUME 🏃‍♂️',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      _textPainter.layout();
      _textPainter.paint(
        canvas,
        Offset(
          size.x / 2 - _textPainter.width / 2,
          size.y / 2 - 25 - _textPainter.height / 2,
        ),
      );

      // Quit Button Background
      final quitRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x / 2 - 100, size.y / 2 + 20, 200, 50),
        const Radius.circular(25),
      );
      final quitPaint = Paint()..color = Colors.redAccent;
      canvas.drawRRect(quitRect, quitPaint);

      // Quit Button Text
      _textPainter.text = const TextSpan(
        text: 'QUIT RUN ❌',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      _textPainter.layout();
      _textPainter.paint(
        canvas,
        Offset(
          size.x / 2 - _textPainter.width / 2,
          size.y / 2 + 45 - _textPainter.height / 2,
        ),
      );
    }

    // Draw correct response soft green glow overlay around viewport edges
    if (_correctFeedbackTimer > 0) {
      final glowPaint = Paint()
        ..color = Colors.green.withValues(alpha: _correctFeedbackTimer * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), glowPaint);
    }

    // Draw wrong response soft orange glow overlay around viewport edges
    if (_wrongFeedbackTimer > 0) {
      final shakeGlowPaint = Paint()
        ..color = Colors.orange.withValues(alpha: _wrongFeedbackTimer * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), shakeGlowPaint);
    }
  }

  void _drawHatOverlay(Canvas canvas, double cx, double cy) {
    if (activeHat == 'none') return;

    if (hatSprite != null) {
      hatSprite!.render(
        canvas,
        position: Vector2(cx - 25, cy - 20),
        size: Vector2(50, 40),
      );
      return;
    }

    // Procedural Fallback if sprite fails
    if (activeHat == 'propeller_hat') {
      _hatPaint.color = Colors.red;
      canvas.drawRect(Rect.fromLTWH(cx - 15, cy - 8, 30, 8), _hatPaint);
      _hatPaint.color = Colors.yellow;
      canvas.drawRect(Rect.fromLTWH(cx - 2, cy - 18, 4, 10), _hatPaint);
      _hatPaint.color = Colors.blue;
      canvas.drawRect(Rect.fromLTWH(cx - 12, cy - 20, 24, 3), _hatPaint);
    } else if (activeHat == 'cowboy_hat') {
      _hatPaint.color = Colors.brown;
      canvas.drawRect(Rect.fromLTWH(cx - 25, cy - 4, 50, 4), _hatPaint); // Brim
      canvas.drawRect(
        Rect.fromLTWH(cx - 15, cy - 16, 30, 12),
        _hatPaint,
      ); // Cap
    } else if (activeHat == 'wizard_hat') {
      _hatPaint.color = Colors.purple;
      final path = Path()
        ..moveTo(cx - 20, cy)
        ..lineTo(cx + 20, cy)
        ..lineTo(cx, cy - 30)
        ..close();
      canvas.drawPath(path, _hatPaint);
    }
  }

  // ─── HORIZONTAL ANSWER LAYOUT (in a line) ───────────────────
  // ─── HORIZONTAL ANSWER LAYOUT (in a line) ───────────────────
  void _drawHorizontalGate(
    Canvas canvas,
    int lane,
    String option,
    double laneWidth,
  ) {
    if (objectY < -30) return; // Guard for clipping at top

    final double laneCenterX = (lane * laneWidth) + (laneWidth * 0.5);
    final double cardWidth = (laneWidth * 0.78).clamp(82.0, 120.0);

    // Bug 3: Dynamic height based on text length
    final double cardHeight = option.length > 6 ? 80.0 : 64.0;

    final double drawnY = objectY;
    final bool selected = currentLane == lane;

    // UI Improvement 2: Lane-specific colors
    Color bgColor;
    Color borderColor;

    if (selected) {
      bgColor = const Color(0xFFFFF9C4);
      borderColor = const Color(0xFFFF9800);
    } else {
      switch (lane) {
        case 0:
          bgColor = const Color(0xFFE8F5E9);
          borderColor = const Color(0xFF66BB6A);
          break;
        case 1:
          bgColor = const Color(0xFFE3F2FD);
          borderColor = const Color(0xFF42A5F5);
          break;
        case 2:
        default:
          bgColor = const Color(0xFFF3E5F5);
          borderColor = const Color(0xFFAB47BC);
          break;
      }
    }

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(laneCenterX, drawnY + 4),
          width: cardWidth,
          height: cardHeight,
        ),
        const Radius.circular(16),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(laneCenterX, drawnY),
        width: cardWidth,
        height: cardHeight,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(rect, Paint()..color = bgColor);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 5 : 2,
    );

    // Selected star decoration
    if (selected) {
      _textPainter.text = const TextSpan(
        text: '⭐',
        style: TextStyle(fontSize: 16),
      );
      _textPainter.layout();
      _textPainter.paint(
        canvas,
        Offset(laneCenterX - 8, drawnY - cardHeight / 2 - 18),
      );
    }

    // Lane label letter
    _textPainter.text = TextSpan(
      text: lane == 0 ? 'A' : (lane == 1 ? 'B' : 'C'),
      style: const TextStyle(fontSize: 11, color: Colors.grey),
    );
    _textPainter.layout();
    _textPainter.paint(
      canvas,
      Offset(laneCenterX - 6, drawnY + cardHeight / 2 - 18),
    );

    // Option text
    final double fontSize = option.length <= 3
        ? 24
        : (option.length <= 6 ? 18 : 14);
    _textPainter.text = TextSpan(
      text: option,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E1B4B),
      ),
    );
    _textPainter.layout(maxWidth: cardWidth - 10);
    _textPainter.paint(
      canvas,
      Offset(
        laneCenterX - _textPainter.width / 2,
        drawnY - _textPainter.height / 2,
      ),
    );
  }
}
