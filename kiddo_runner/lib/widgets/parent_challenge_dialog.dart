import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../state/settings_provider.dart';

class ParentChallengeDialog extends StatefulWidget {
  const ParentChallengeDialog({super.key});

  @override
  State<ParentChallengeDialog> createState() => _ParentChallengeDialogState();
}

class _ParentChallengeDialogState extends State<ParentChallengeDialog> {
  final _answerController = TextEditingController();
  late int _numA;
  late int _numB;
  late String _operator;
  late int _correctAnswer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    final type = random.nextInt(4); // 0: +, 1: -, 2: *, 3: /
    if (type == 0) {
      _numA = random.nextInt(15) + 5; // 5 to 19
      _numB = random.nextInt(15) + 5; // 5 to 19
      _operator = '+';
      _correctAnswer = _numA + _numB;
    } else if (type == 1) {
      _numA = random.nextInt(20) + 15; // 15 to 34
      _numB = random.nextInt(10) + 5; // 5 to 14
      _operator = '-';
      _correctAnswer = _numA - _numB;
    } else if (type == 2) {
      _numA = random.nextInt(8) + 3; // 3 to 10
      _numB = random.nextInt(6) + 2; // 2 to 7
      _operator = 'x';
      _correctAnswer = _numA * _numB;
    } else {
      _numB = random.nextInt(5) + 2; // 2 to 6
      _correctAnswer = random.nextInt(6) + 2; // 2 to 7
      _numA = _numB * _correctAnswer;
      _operator = '/';
    }
    _answerController.clear();
    _errorMessage = null;
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _errorMessage = null;
    });
    final text = _answerController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an answer.';
      });
      return;
    }
    final parsed = int.tryParse(text);
    if (parsed == null || parsed != _correctAnswer) {
      setState(() {
        _errorMessage = 'That answer is not correct. Please try again.';
      });
      return;
    }

    // Success! Extend time
    final settingsProv = Provider.of<SettingsProvider>(context, listen: false);
    settingsProv.addExtraPlayMinutesToday(30);

    Navigator.of(context).pop(true); // Return true for success
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(Icons.security_rounded, color: AppColors.primary500, size: 28),
          SizedBox(width: 10),
          Text(
            'Parent Challenge 🔑',
            style: TextStyle(
              fontFamily: AppTextStyles.primaryFont,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Answer this question to unlock 30 more minutes today.',
              style: TextStyle(
                fontFamily: AppTextStyles.primaryFont,
                fontSize: 14,
                color: AppColors.neutral600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary100, width: 2),
              ),
              child: Text(
                '$_numA $_operator $_numB = ?',
                style: const TextStyle(
                  fontFamily: AppTextStyles.primaryFont,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Your answer',
                filled: true,
                fillColor: AppColors.neutral50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.neutral200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary500,
                    width: 2,
                  ),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontFamily: AppTextStyles.primaryFont,
                  fontSize: 13,
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'CANCEL',
            style: TextStyle(
              fontFamily: AppTextStyles.primaryFont,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral500,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _submit,
          child: const Text(
            'SUBMIT',
            style: TextStyle(
              fontFamily: AppTextStyles.primaryFont,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
