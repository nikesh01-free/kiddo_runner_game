class MistakeHistory {
  MistakeHistory({
    required this.id,
    required this.childProfileId,
    required this.questionText,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.mode,
    required this.createdAt,
  });

  final String id;
  final String childProfileId;
  final String questionText;
  final String selectedAnswer;
  final String correctAnswer;
  final String mode;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_profile_id': childProfileId,
      'question_text': questionText,
      'selected_answer': selectedAnswer,
      'correct_answer': correctAnswer,
      'mode': mode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MistakeHistory.fromMap(Map<dynamic, dynamic> map) {
    return MistakeHistory(
      id: map['id'] as String,
      childProfileId: map['child_profile_id'] as String,
      questionText: map['question_text'] as String,
      selectedAnswer: map['selected_answer'] as String,
      correctAnswer: map['correct_answer'] as String,
      mode: map['mode'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
