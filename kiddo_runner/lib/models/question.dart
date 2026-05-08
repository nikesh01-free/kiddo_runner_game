class Question {
  Question({
    required this.id,
    required this.ageGroup,
    required this.mode,
    required this.topic,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.correctOption,
  });

  final String id;
  final String ageGroup;
  final String mode; // 'math' or 'spelling'
  final String topic; // 'addition', 'subtraction', 'spell_3', etc.
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String correctOption; // 'A', 'B', or 'C'

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'age_group': ageGroup,
      'mode': mode,
      'topic': topic,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'correct_option': correctOption,
    };
  }

  factory Question.fromMap(Map<dynamic, dynamic> map) {
    return Question(
      id: map['id'] as String,
      ageGroup: map['age_group'] as String,
      mode: map['mode'] as String,
      topic: map['topic'] as String,
      questionText: map['question_text'] as String,
      optionA: map['option_a'] as String,
      optionB: map['option_b'] as String,
      optionC: map['option_c'] as String,
      correctOption: map['correct_option'] as String,
    );
  }
}
